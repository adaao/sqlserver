/*CRIAÇÃO DO BANCO E TABELAS*/
create database Almoxarifado_AS
go
use Almoxarifado_AS
go

/*CRIACAO DAS TABELAS*/

create table Clientes (cd_Cliente int not null, CNPJ_Cliente CHAR(13), ds_Endereco char(40), nr_Telefone char(10), nm_Cliente char(40));

create table Peca (cd_UPC int not null, nr_Serie int, nr_VolumePeca int, vl_Peca money not null, qt_EstoqueMinimo int not null, qt_emEstoque int, ds_Peca char(15) not null);

create table PedidoPeca (cd_Pedido int not null, dt_Pedido date, ds_ConfBusca char(10), cd_Cliente int); /*FK*/

create table Itens_Pedidos (cd_Pedido int, qt_Peca int, cd_UPC int);/*FK*//*FK*/

create table PedidosPecas_Finalizados (cd_Pedido int, qt_Item int, cd_UPC int);/*FK*//*FK*/

create table Peca_Requisicao (qt_emEstoque int, qt_Comprar int, cd_UPC int);/*FK*/

create table ItensOrdem_Compra (cd_Ordem int, cd_UPC int, qt_Peca int);/*FK*/

create table Receptaculo (cd_Receptaculo char(5) not null, cd_UPC int, qt_Item int, SgFull char(1), nr_Capacidade int, ds_Peca char(15));/*FK*//*FK*/

create table Historico_Precos (cd_AlteracaoPreco int not null, vl_Peca money, vl_PrecoNovo money, dt_Alteracao date, cd_UPC int, cd_Usuario int);/*FK*//*FK*//*FK*/

create table HistoricoPecas_Excluidas (cd_Usuario int, ds_Peca char(15), dt_Exclusao date, cd_UPC int);/*FK*//*FK*//*FK*/

create table Usuario (cd_Usuario int not null, nm_Usuario char(40), isLogado int default 0);

create table TentativasLog (cd_Tentativa int not null, cd_Usuario int, dt_Tentativa date, cd_Operacao int, cd_UPC int);/*FK*//*FK*//*FK*/

create table Operacoes (cd_Operacao int not null, ds_Operacao char(30));

create table Fornecedor (cd_Fornecedor int not null, nm_Fornecedor char(40), ds_Endereco char(40), cd_CNPJ char(14), cd_Telefone char(10) );

create table Ordem_de_Compra (cd_Ordem int not null, cd_Fornecedor int, dt_Ordem date, ic_Pendente char(1), vl_TotalOrdem money);

create table Entrega (cd_Entrega int not null, dt_Entrega date);

create table Pedidos_Finalizados (cd_Pedido int, dt_Pedido date, cd_Cliente int); /*finalizar ordem de compra*/


/*CRIAÇÃO DAS CHAVES PRIMARIAS*/
alter table Clientes
add primary key (cd_Cliente)
go

alter table Peca
add primary key (cd_UPC)
go

alter table PedidoPeca
add primary key (cd_Pedido)
go

alter table Receptaculo
add primary key (cd_Receptaculo)
go

alter table Historico_Precos
add primary key (cd_AlteracaoPreco)
go

alter table Usuario
add primary key (cd_Usuario)
go

alter table TentativasLog
add primary key (cd_Tentativa)
go

alter table Operacoes
add primary key (cd_Operacao)
go 

alter table Fornecedor
add primary key (cd_Fornecedor)
go

alter table Ordem_de_Compra
add primary key (cd_Ordem)
go

alter table Entrega
add primary key (cd_Entrega)
go

/*CRIAÇÃO DAS CHAVES ESTRANGEIRAS*/
alter table PedidoPeca
add foreign key (cd_Cliente)
references Clientes
go 

alter table Itens_Pedidos
add foreign key (cd_Pedido)
references PedidoPeca
go 

alter table Itens_Pedidos
add foreign key (cd_UPC)
references Peca
go 

alter table PedidosPecas_Finalizados
add foreign key (cd_Pedido)
references PedidoPeca
go 

alter table PedidosPecas_Finalizados
add foreign key (cd_UPC)
references Peca
go 

alter table Peca_Requisicao
add foreign key (cd_UPC)
references Peca
go 

alter table ItensOrdem_Compra
add foreign key (cd_Ordem)
references Ordem_de_Compra
go 

alter table ItensOrdem_Compra
add foreign key (cd_UPC)
references Peca
go 

alter table Receptaculo
add foreign key (cd_UPC)
references Peca
go 


alter table Historico_Precos
add foreign key (cd_UPC)
references Peca
go
 

alter table Historico_Precos
add foreign key (cd_Usuario)
references Usuario
go 

alter table HistoricoPecas_Excluidas
add foreign key (cd_Usuario)
references Usuario
go 

 
alter table HistoricoPecas_Excluidas
add foreign key (cd_UPC)
references Peca
go 
alter table TentativasLog
add foreign key (cd_Usuario)
references Usuario
go 
alter table TentativasLog
add foreign key (cd_Operacao)
references Operacoes
go 

alter table TentativasLog
add foreign key (cd_UPC)
references Peca
go 

alter table Pedidos_Finalizados
add foreign key (cd_Pedido)
references PedidoPeca
go 

alter table Pedidos_Finalizados
add foreign key (cd_Cliente)
references Clientes
go 
