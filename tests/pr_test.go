// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"bytes"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"log"
	"math/big"
	"os"
	"strings"
	"testing"
	"time"

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
const rhelaiImageName = "rhel-ai-nvidia-1.4-1739107849-x86_64-kvm.qcow2"
const vsiMachineType = "gx3-48x240x2l40s"

var sharedInfoSvc *cloudinfo.CloudInfoService
var permanentResources map[string]interface{}

// for included modules for each solution
var tarAdditionalIncludePatterns []string
var rhelaiImageCosUrl string
var rhelaiModelCosCrn string
var rhelaiModelCosBucketName string
var rhelaiModelCosRegion string

// TLS certs for tests needing https
var tlsTestCert string
var tlsTestCertPriv string

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
	rhelaiImageCosUrl = permanentResources["rhelai_image_cos_bucket_url"].(string) + "/" + rhelaiImageName
	rhelaiModelCosCrn = permanentResources["general_test_storage_cos_instance_crn"].(string)
	rhelaiModelCosBucketName = permanentResources["rhelai_model_cos_bucket_name"].(string)
	rhelaiModelCosRegion = permanentResources["general_test_storage_cos_instance_region"].(string)

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

// Consistency test for the basic example
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
		Prefix:                 "rai_vpcpub",
		Region:                 "eu-es",
		DeleteWorkspaceOnFail:  true,
		WaitJobCompleteMinutes: 90,
		CloudInfoService:       sharedInfoSvc,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "zone", Value: options.Region + "-1", DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "resource_group", Value: resourceGroup, DataType: "string"},
		{Name: "image_url", Value: rhelaiImageCosUrl, DataType: "string"},
		{Name: "machine_type", Value: vsiMachineType, DataType: "string"},
		{Name: "enable_private_only", Value: false, DataType: "bool"},
		{Name: "enable_https", Value: true, DataType: "bool"},
		{Name: "ssh_key", Value: publicKey, DataType: "string"},
		{Name: "ssh_private_key", Value: privateKey, DataType: "string", Secure: true},
		{Name: "https_certificate", Value: tlsTestCert, DataType: "string"},
		{Name: "https_privatekey", Value: tlsTestCertPriv, DataType: "string"},
		{Name: "model_apikey", Value: modelKey, DataType: "string", Secure: true},
		{Name: "bucket_name", Value: rhelaiModelCosBucketName, DataType: "string"},
		{Name: "cos_region", Value: rhelaiModelCosRegion, DataType: "string"},
		{Name: "crn_service_id", Value: rhelaiModelCosCrn, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

// Upgrade test (using advanced example)
func TestRunVpcSolutionPublicUpgradeSchematic(t *testing.T) {
	t.Parallel()
	t.Skip("Skipping on first version, remove immediatly after 1.0 release")

	tarIncludePatterns := append(tarAdditionalIncludePatterns, "solutions/rhelai_vpc/*")

	publicKey, privateKey := genNewSshKeypair(t)

	// this is a throwaway random key needed for the test
	modelKey := uuid.NewString()

	// set up a schematics test
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                t,
		TarIncludePatterns:     tarIncludePatterns,
		TemplateFolder:         vpcSolutionDir,
		Prefix:                 "rai_vpc_upg",
		Region:                 "eu-es",
		DeleteWorkspaceOnFail:  true,
		WaitJobCompleteMinutes: 90,
		CloudInfoService:       sharedInfoSvc,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "zone", Value: options.Region + "-1", DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "resource_group", Value: resourceGroup, DataType: "string"},
		{Name: "image_url", Value: rhelaiImageCosUrl, DataType: "string"},
		{Name: "machine_type", Value: vsiMachineType, DataType: "string"},
		{Name: "enable_private_only", Value: false, DataType: "bool"},
		{Name: "enable_https", Value: true, DataType: "bool"},
		{Name: "ssh_key", Value: publicKey, DataType: "string"},
		{Name: "ssh_private_key", Value: privateKey, DataType: "string", Secure: true},
		{Name: "https_certificate", Value: tlsTestCert, DataType: "string"},
		{Name: "https_privatekey", Value: tlsTestCertPriv, DataType: "string"},
		{Name: "model_apikey", Value: modelKey, DataType: "string", Secure: true},
		{Name: "bucket_name", Value: rhelaiModelCosBucketName, DataType: "string"},
		{Name: "cos_region", Value: rhelaiModelCosRegion, DataType: "string"},
		{Name: "crn_service_id", Value: rhelaiModelCosCrn, DataType: "string"},
	}

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

// helper function to generate an SSH key pair for testing
func genNewSshKeypair(t *testing.T) (string, string) {
	rsaKeyPair, _ := ssh.GenerateRSAKeyPairE(t, 4096)
	sshPublicKey := strings.TrimSuffix(rsaKeyPair.PublicKey, "\n") // removing trailing new lines
	sshPrivateKey := "<<EOF\n" + rsaKeyPair.PrivateKey + "EOF"

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

	certPrivKey, certPrivErr := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if certPrivErr != nil {
		return "", "", certPrivErr
	}

	// SELF SIGN THE CERT
	certBytes, certBytesErr := x509.CreateCertificate(rand.Reader, cert, cert, &certPrivKey.PublicKey, certPrivKey)
	if certBytesErr != nil {
		return "", "", certBytesErr
	}

	// PEM ENCODE
	certPEM := new(bytes.Buffer)
	pem.Encode(certPEM, &pem.Block{
		Type:  "CERTIFICATE",
		Bytes: certBytes,
	})

	certPrivBytes, certPrivBytesErr := x509.MarshalPKCS8PrivateKey(certPrivKey)
	if certPrivBytesErr != nil {
		return "", "", certPrivBytesErr
	}

	certPrivKeyPEM := new(bytes.Buffer)
	pem.Encode(certPrivKeyPEM, &pem.Block{
		Type:  "PRIVATE KEY",
		Bytes: certPrivBytes,
	})

	return certPEM.String(), certPrivKeyPEM.String(), nil
}
