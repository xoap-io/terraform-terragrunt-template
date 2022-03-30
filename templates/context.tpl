context = {
    organization = "${organisation}"
    environment  = "${environment}"
    account      = "${account_id}"
    product      = "${product}"
    tags         = {
    %{ for key,value in tags ~}
    ${key} =  "${value}"
    %{ endfor ~}
    }
}