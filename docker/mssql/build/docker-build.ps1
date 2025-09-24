
get-content .arg | foreach {
    if ( $_ -like '^#.*' ) { continue }
    if ( $_ )
    {
        $name, $value = $_.split('=')
        New-Variable -Name $name -Value $value -Force
    }
}

docker build `
    --build-arg "REGISTRY=${REGISTRY}" `
    --build-arg "OS_TAG=${OS_TAG}" `
    --build-arg "MSSQL_VERSION=${MSSQL_VERSION}" `
    --build-arg "DISTR_URL=${DISTR_URL}" `
    --build-arg "DISTR_NAME=${DISTR_NAME}" `
    --build-arg "UPD_URL=${UPD_URL}" `
    -t "${REGISTRY}${MSSQL_TAG}" `
    .

if ( ( $args[0] -eq "push" ) -and ( $REGISTRY ) )
{
    docker push "${REGISTRY}${MSSQL_TAG}"
}