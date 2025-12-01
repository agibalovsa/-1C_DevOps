mkdir "build_context" -Force

Copy-Item "../common_context/build/*" "build_context/" -Force
Copy-Item "context/*" "build_context/"
Copy-Item ".arg" "build_context/.arg"

. "build_context/tools.ps1"

Set-Vars-From-File "build_context/.arg"

docker build `
    --build-arg "REGISTRY=${REGISTRY}" `
    --build-arg "OS_TAG=${OS_TAG}" `
    --build-arg "MSSQL_VERSION=${MSSQL_VERSION}" `
    --build-arg "DISTR_URL=${DISTR_URL}" `
    --build-arg "DISTR_NAME=${DISTR_NAME}" `
    --build-arg "UPD_URL=${UPD_URL}" `
    -t "${REGISTRY}${MSSQL_TAG}" `
    .

if ( ( $args.Length -gt 0 ) -and ( $args[0] = "push" ) -and ( ! ( [string]::IsNullOrEmpty($REGISTRY) ) ) )
{
    docker push "${REGISTRY}${MSSQL_TAG}"
}

Remove-Item build_context -Force -Recurse