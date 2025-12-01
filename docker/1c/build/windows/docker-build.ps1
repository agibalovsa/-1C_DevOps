mkdir build_context -Force

Copy-Item "../../../common_context/build/*" "build_context/" -Force
Copy-Item "context/*" "build_context/"
Copy-Item ".arg" "build_context/.arg"

. ./build_context/tools.ps1

Set-Vars-From-File "./build_context/.arg"

docker build `
  --build-arg "REGISTRY=${REGISTRY}" `
  --build-arg "OS_TAG=${OS_TAG}" `
  --build-arg "OC_VERSION=${OC_VERSION}" `
  --build-arg "OC_MODE=${OC_MODE}" `
  -t "${REGISTRY}${OC_TAG}" `
  .

if ( ( $args.Length -gt 0 ) -and ( $args[0] = "push" ) -and ( ! ( [string]::IsNullOrEmpty($REGISTRY) ) ) )
{
    docker push "${REGISTRY}${OC_TAG}"
}

rmdir build_context -Force -Recurse