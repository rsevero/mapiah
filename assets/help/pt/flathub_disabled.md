# Atualização disponível

Há versões mais recentes do Mapiah disponíveis, mas esta versão do Flathub não é mais atualizada.

Instruções de atualização (no terminal):

```
# Remova esta versão do Mapiah.
flatpak remove io.github.rsevero.mapiah
# Instale a versão mais recente do Mapiah do Github.
flatpak install --user --from https://rsevero.github.io/mapiah/org.mapiah.mapiah.flatpakref
```

Se quiser, você também pode verificar mais informações na página do Mapiah no Flathub: [Mapiah no Flathub](https://flathub.org/apps/details/io.github.rsevero.mapiah)

## Justificativa
A compilação do Mapiah no Flathub não é mais mantida devido aos seguintes fatores:

- O processo de compilação é extremamente lento, consome muitos recursos e envolve múltiplas etapas manuais;
- As restrições do Flathub em relação a aplicações externas obrigam o Mapiah a incluir o Therion e suas dependências, aumentando o tamanho do pacote de aproximadamente 14MB para mais de 950MB;
- O Therion incluído no pacote é consideravelmente mais lento do que o instalado nativamente.
