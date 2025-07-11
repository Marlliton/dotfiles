function take --description "Cria um diretório e entra nele"
    mkdir -p "$argv[1]"
    and cd "$argv[1]"
end
