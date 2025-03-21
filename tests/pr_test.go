// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"bytes"
	"crypto/ecdsa"
	"crypto/elliptic"
	crypto_rand "crypto/rand"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"log"
	"math/big"
	"os"
	"testing"
	"time"

	"math/rand"

	"github.com/google/uuid"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// Ensure every example directory has a corresponding test
const vpcSolutionDir = "solutions/rhelai_vpc"

// additional constants for test
const vsiMachineType = "gx3-48x240x2l40s" // smaller that wasn't working = gx3-24x120x1l40s

var sharedInfoSvc *cloudinfo.CloudInfoService
var permanentResources map[string]interface{}

// for included modules for each solution
var tarAdditionalIncludePatterns []string
var rhelaiImageCosUrl string
var rhelaiModelCosBucketCrn string
var rhelaiModelCosBucketName string
var rhelaiModelCosRegion string

// TLS certs for tests needing https
var tlsTestCert string
var tlsTestCertPriv string

// for picking random zone, set in TestMain
var zoneList []string

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	// set up some values used for every test
	rhelaiImageCosUrl = permanentResources["rhelai_image_cos_bucket_url"].(string)
	rhelaiModelCosBucketCrn = permanentResources["rhelai_model_cos_bucket_crn"].(string)
	rhelaiModelCosBucketName = permanentResources["rhelai_model_cos_bucket_name"].(string)
	rhelaiModelCosRegion = permanentResources["rhelai_model_cos_bucket_region"].(string)
	zoneList = []string{"1", "2", "3"}

	// generate throwaway TLS certs for the test
	var certErr error
	tlsTestCert, tlsTestCertPriv, certErr = genNewTlsCert()
	if certErr != nil {
		log.Fatal(certErr)
	}

	tarAdditionalIncludePatterns = []string{
		"modules/ilab_conf/*",
		"modules/ilab_conf/ansible/*",
		"modules/ilab_conf/ansible/roles/proxy/tasks/*",
		"modules/ilab_conf/config/*",
		"modules/model/*",
		"modules/model/ansible-files/*",
		"modules/model/ansible-files/roles/ilab/tasks/*",
		"modules/rhelai_instance/*",
		"modules/rhelai_vpc/*",
	}

	os.Exit(m.Run())
}

// DEV NOTE: the full rhelai_vpc solution allows ansible to connect to VSI from IBM Cloud internal and
// Schematics only. Therefore the tests for that solution will need to remain schematics tests.
// Consistency test for the rhelai_vpc solution, with public option enabled.
func TestRunVpcSolutionPublicSchematic(t *testing.T) {
	t.Parallel()

	tarIncludePatterns := append(tarAdditionalIncludePatterns, "solutions/rhelai_vpc/*")

	publicKey, privateKey := genNewSshKeypair(t)

	// this is a throwaway random key needed for the test
	modelKey := uuid.NewString()

	// set up a schematics test
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                t,
		TarIncludePatterns:     tarIncludePatterns,
		TemplateFolder:         vpcSolutionDir,
		Prefix:                 "rai-vpcpubs",
		Region:                 "eu-es",
		DeleteWorkspaceOnFail:  true,
		WaitJobCompleteMinutes: 90,
		CloudInfoService:       sharedInfoSvc,
	})

	randomZone := zoneList[rand.Intn(len(zoneList))]

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "zone", Value: randomZone, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_resource_group", Value: resourceGroup, DataType: "string"},
		{Name: "image_url", Value: rhelaiImageCosUrl, DataType: "string"},
		{Name: "machine_type", Value: vsiMachineType, DataType: "string"},
		{Name: "enable_private_only", Value: false, DataType: "bool"},
		{Name: "ssh_key", Value: publicKey, DataType: "string"},
		{Name: "ssh_private_key", Value: privateKey, DataType: "string", Secure: true},
		{Name: "model_apikey", Value: modelKey, DataType: "string", Secure: true},
		{Name: "model_cos_bucket_name", Value: rhelaiModelCosBucketName, DataType: "string"},
		{Name: "model_cos_region", Value: rhelaiModelCosRegion, DataType: "string"},
		{Name: "model_cos_bucket_crn", Value: rhelaiModelCosBucketCrn, DataType: "string"},
		{Name: "enable_https", Value: true, DataType: "bool"},
		{Name: "https_certificate", Value: tlsTestCert, DataType: "string"},
		{Name: "https_privatekey", Value: tlsTestCertPriv, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

// DEV NOTE: the full rhelai_vpc solution allows ansible to connect to VSI from IBM Cloud internal and
// Schematics only. Therefore the tests for that solution will need to remain schematics tests.
// UPGRADE test for the rhelai_vpc solution, with public option enabled.
func TestRunVpcSolutionPublicUpgradeSchematic(t *testing.T) {
	t.Skip("Solution is still in Beta and has not been released, skipping upgrade tests until solution finalized")
	t.Parallel()

	tarIncludePatterns := append(tarAdditionalIncludePatterns, "solutions/rhelai_vpc/*")

	publicKey, privateKey := genNewSshKeypair(t)

	// this is a throwaway random key needed for the test
	modelKey := uuid.NewString()

	randomZone := zoneList[rand.Intn(len(zoneList))]

	// set up a schematics test
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                t,
		TarIncludePatterns:     tarIncludePatterns,
		TemplateFolder:         vpcSolutionDir,
		Prefix:                 "rai-vpc-upg",
		Region:                 "eu-es",
		DeleteWorkspaceOnFail:  true,
		WaitJobCompleteMinutes: 90,
		CloudInfoService:       sharedInfoSvc,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "zone", Value: randomZone, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_resource_group", Value: resourceGroup, DataType: "string"},
		{Name: "image_url", Value: rhelaiImageCosUrl, DataType: "string"},
		{Name: "machine_type", Value: vsiMachineType, DataType: "string"},
		{Name: "enable_private_only", Value: false, DataType: "bool"},
		{Name: "ssh_key", Value: publicKey, DataType: "string"},
		{Name: "ssh_private_key", Value: privateKey, DataType: "string", Secure: true},
		{Name: "model_apikey", Value: modelKey, DataType: "string", Secure: true},
		{Name: "model_cos_bucket_name", Value: rhelaiModelCosBucketName, DataType: "string"},
		{Name: "model_cos_region", Value: rhelaiModelCosRegion, DataType: "string"},
		{Name: "model_cos_bucket_crn", Value: rhelaiModelCosBucketCrn, DataType: "string"},
		{Name: "enable_https", Value: true, DataType: "bool"},
		{Name: "https_certificate", Value: tlsTestCert, DataType: "string"},
		{Name: "https_privatekey", Value: tlsTestCertPriv, DataType: "string"},
	}

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

// helper function to generate an SSH key pair for testing
func genNewSshKeypair(t *testing.T) (string, string) {
	rsaKeyPair, _ := ssh.GenerateRSAKeyPairE(t, 4096)
	sshPublicKey := rsaKeyPair.PublicKey
	sshPrivateKey := rsaKeyPair.PrivateKey

	return sshPublicKey, sshPrivateKey
}

// helper function to create a valid self-signed TLS cert for https server
// inspriation from this example: https://go.dev/src/crypto/tls/generate_cert.go
// outputs: cert, private key, error
func genNewTlsCert() (string, string, error) {

	// CREATE THE TLS CERT
	cert := &x509.Certificate{
		SerialNumber: big.NewInt(1658),
		Subject: pkix.Name{
			Organization: []string{"IBM"},
		},
		NotBefore:   time.Now(),
		NotAfter:    time.Now().AddDate(0, 1, 0), // 1 month
		ExtKeyUsage: []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		KeyUsage:    x509.KeyUsageDigitalSignature,
		IsCA:        true,
	}

	certPrivKey, certPrivErr := ecdsa.GenerateKey(elliptic.P256(), crypto_rand.Reader)
	if certPrivErr != nil {
		return "", "", certPrivErr
	}

	// SELF SIGN THE CERT
	certBytes, certBytesErr := x509.CreateCertificate(crypto_rand.Reader, cert, cert, &certPrivKey.PublicKey, certPrivKey)
	if certBytesErr != nil {
		return "", "", certBytesErr
	}

	// PEM ENCODE
	certPEM := new(bytes.Buffer)
	pubPemEncodeErr := pem.Encode(certPEM, &pem.Block{
		Type:  "CERTIFICATE",
		Bytes: certBytes,
	})
	if pubPemEncodeErr != nil {
		return "", "", pubPemEncodeErr
	}

	certPrivBytes, certPrivBytesErr := x509.MarshalPKCS8PrivateKey(certPrivKey)
	if certPrivBytesErr != nil {
		return "", "", certPrivBytesErr
	}

	certPrivKeyPEM := new(bytes.Buffer)
	privPemEncodeErr := pem.Encode(certPrivKeyPEM, &pem.Block{
		Type:  "PRIVATE KEY",
		Bytes: certPrivBytes,
	})
	if privPemEncodeErr != nil {
		return "", "", privPemEncodeErr
	}

	return certPEM.String(), certPrivKeyPEM.String(), nil
}
