# JCL

**Versão atual:** commit 77ae8ebeb3878829b8571333a855851a689cd19d do branch **master** de 10/09/2021. 

Observar que a JCL em si não é compatível com o FreePascal e no passado foi criado este fork
que foi sendo gradualmente modificado para tornar compatível. Essa abordagem tornou possível a 
criação da versão Linux do Engine, no entanto cria dificuldades para sincronizar o repositório. 
Abaixo estão os detalhes de como sincronizar o repositório e as principais correções que 
precisam ser verificadas a fim de evitar uma regressão da compatibilidade com o Linux.

O repositório https://github.com/Makhaon/jcl contém várias alterações de compatibilidade e o 
pull request https://github.com/project-jedi/jcl/pull/41 tenta integrar essas alterações
no repositório do jcl. Deste repositório, aproveitamos o arquivo common/FpLibcCompatibility.pas.

### Passos para atualizar a JCL

1. Execute o instalador do JCL (install.bat). Em cada aba associada a versão do Delphi:

	* Desmarque a opção *Wrapper options*
	* Desmarque a opção *Environment*
	* Desmarque a opção *Make library units*
	* Desmarque a opção *Packages*
	* Desmarque a opção *Enable thread safe code* (o Engine utiliza locks próprios para 
    sincronizar o uso das classes da JCL)
	* Configure a precisão de ponto flutuante para DOUBLE

2. Copie os diretórios abaixo para o diretório jcl do repositório: 

	* jcl\source\common
	* jcl\source\include
	* jcl\source\vcl
	* jcl\source\windows

3. Remova os diretórios:

	* jcl\windows\obj (o objetivo é garantir que a ZLIB não será embarcada estaticamente)
	* jcl\include\jedi\.git

4. Revisar cada arquivo alterado para não desfazer modificações necessárias para o suporte ao FPC
ou Linux. Ter atenção especial com os seguintes arquivos:
   
   * JclAbstractContainers: seUTF8 => TJclAnsiStrEncoding.seUTF8.
   * JclAnsiStrings: inclusão da FpLibcCompatibility.
   * JclDateTime: implementação de funções de conversão de data para o Linux.
   * JclFileUtils: IFDEFs para APIs do Windows. Foram muitas alterações. É mais produtivo aplicar
   apenas as alterações desse arquivo no histórico do projeto Jcl.
   * JclSynch, JclLogic e JclMath: todas as funções com assembler e IFDEFs para códigos que
   utilizam APIs do Windows. Por segurança, deve-se evitar sincronizar alterações nesses units.
   * JclStreams e JclStringConversions: IFDEFs para classes que utilizam APIs do Windows. 
   Compatibilidade das classes TJclHandleStream e TJclFileStream com FPC/Linux.
   * JclStringLists: TJclInterfacedStringList e TJclStringList compatíveis com FPC.
   * JclStrings: IFDEF em CharType para Windows.
   * jcl.inc: desativar LOCALSYMBOLS, DEFINITIONINFO e REFERENCEINFO para o FPC.
   * JclUnicode: IFDEF em TSearchEngine para o Windows.
   * JclSysInfo e JclSysUtils: diversas APIs revistas para compatibilizar com o FPC.
