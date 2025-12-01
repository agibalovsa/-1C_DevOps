mkdir "build_context" -Force

Copy-Item "../../common_context/build/tools.ps1" "build_context/tools.ps1" -Force
Copy-Item context/* "build_context/"
Copy-Item ".arg" "build_context/.arg"

. "build_context/tools.ps1"

Set-Vars-From-File "build_context/.arg"

docker pull "${OS_EXT_TAG}"

docker build `
    --build-arg "OS_EXT_TAG=${OS_EXT_TAG}" `
    -t "${REGISTRY}${OS_TAG}" `
    .

if ( ( $args.Length -gt 0 ) -and ( $args[0] = "push" ) -and ( ! ( [string]::IsNullOrEmpty($REGISTRY) ) ) )
{
    docker push "${REGISTRY}${OS_TAG}"
}

Remove-Item build_context -Force -Recurse