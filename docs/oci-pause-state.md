# OCI Pause State

Date: 2026-06-06

Current state:
- OCI VCN/networking created.
- OKE Basic cluster created and ACTIVE.
- OKE node pool failed repeatedly.
- No worker nodes are running.
- Node pool was removed from Terraform state after failed creation.
- Real local terraform.tfvars is ignored by Git.
- Current blocker: OCI OKE node pool creation fails with "Work request exceeded max retry count".

Next debugging:
1. Do not retry blindly.
2. Inspect node pool Terraform resource.
3. Consider OCI provider upgrade.
4. Consider changing shape from VM.Standard.E4.Flex to E5/Flex or A1/Flex.
5. Confirm if failed node pool exists in OCI Console.
6. Then retry one controlled node pool apply only.
