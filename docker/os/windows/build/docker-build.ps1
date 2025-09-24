
get-content .arg | foreach {
    if ( $_ -like '^#.*' ) { continue }
    if ( $_ )
    {
        $name, $value = $_.split('=')
        New-Variable -Name $name -Value $value -Force
    }
}

docker pull "${OS_EXT_TAG}"

docker build `
    --build-arg "OS_EXT_TAG=${OS_EXT_TAG}" `
    -t "${REGISTRY}${OS_TAG}" `
    .

if ( ( $args[0] -eq "push" ) -and ( $REGISTRY ) )
{
    docker push "${REGISTRY}${OS_TAG}"
}