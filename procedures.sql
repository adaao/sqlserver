/*PROCEDURES E TRIGGERS*/

/*
1-Elabore uma procedure para efetuar o recebimento do estoque de uma peça. 
A procedure deverá receber três parâmetros de 
entrada (pedido, código da peça e quantidade de entrada). 
Além de gerar uma tabela de PedidoPeça para armazenar as peças de cada pedido, 
deve também atualizar o quantidade de estoque da tabela de Peças
*/

CREATE PROCEDURE sp_recebeEstoque
	@cdOrdemDeCompra INT,
	@cdUpcPeca INT,
	@qtPeca INT
AS
	UPDATE ItensOrdem_Compra 
		SET qt_Peca = qt_Peca - @qtPeca
		WHERE cd_Ordem = @cdOrdemDeCompra AND cd_UPCPeca = @cdUpcPeca;
	GO

	UPDATE Peca
		SET qt_emEstoque = qt_emEstoque + @qt_peca
		WHERE cd_UPC = @cdUpcPeca;
	GO

	EXEC sp_gerarDistribuicaoPeloEstoque @cdUpcPeca, @qtPeca;
	GO

	EXEC sp_verificaPendenciasDaOrdemDeCompra;
	GO
END
GO

CREATE PROCEDURE sp_gerarDistribuicaoPeloEstoque
	@cdUpcPeca INT,
	@qtPeca INT,
AS
	DECLARE @
	WHILE (@qtPeca > 0)
	BEGIN
		
	END
END
GO

CREATE PROCEDURE sp_verificaPendenciasDaOrdemDeCompra
	@cd_Ordem
AS
	IF (SELECT SUM(qt_Peca)) = 0

		

/*
2. Elabore uma procedure para fazer uma cópia dos dados de um pedido de um determinado mês e ano,
 em uma tabela denominada Pedidos_finalizados, e todos os seus itens de PedidoPeça
 sejam armazenados em uma tabela denominada PedidosPeças_finalizados. Após a cópia,
 o pedido e seus itens serão excluídos.
*/

CREATE PROCEDURE sp_finalizaPedidos
@mes INT,
@ano INT
AS
BEGIN
	IF EXISTS (SELECT cd_Pedido FROM PedidoPeca WHERE 
						MONTH(dt_Pedido) = @mes AND YEAR(dt_Pedido) = @ano)

	BEGIN
		INSERT INTO 
			Pedidos_Finalizados 
			SELECT cd_Pedido, dt_Pedido, cd_Cliente FROM PedidoPeca WHERE MONTH(dt_Pedido) = @mes AND YEAR(dt_Pedido) = @ano 

		INSERT INTO 
			PedidosPecas_Finalizados 
			SELECT cd_Pedido, qt_Peca, cd_UPC FROM Itens_Pedidos WHERE
			 cd_Pedido = (SELECT cd_Pedido FROM PedidoPeca WHERE MONTH(dt_Pedido) = @mes AND YEAR(dt_Pedido) = @ano)

	END
	ELSE
	IF NOT EXISTS (SELECT cd_Pedido FROM PedidoPeca WHERE MONTH(dt_Pedido) = @mes AND YEAR(dt_Pedido) = @ano)
		PRINT 'Não existem pedidos do ano ou mês solicitado'
END
--fim da procedure
--revisada
--testada




/*
3. Elabore uma procedure para efetuar a comparação entre estoque mínimo e estoque atual de uma peça.
 Caso o estoque esteja abaixo do estoque mínimo, será armazenado em uma tabela 
 peça_requisicao (codigo, qtd em estoque, qtd a comprar). 
 Se for necessário, inclua o atributo estoque mínimo na tabela de peças.
*/

CREATE PROCEDURE sp_verificaEstoque
	@cdUpcPeca INT
AS
	DECLARE @qt_estocada INT, @estqMin INT;
	--ARMAZENA A QUANTIDADE EM ESTOQUE DE UMA DETERMINADA PECA
	SET @qt_estocada = (SELECT P.qt_emEstoque FROM 
						Peca P WHERE P.cd_UPC = @cdUpcPeca
						);
						
	--ARMAZENA A QUANTIDADE MINIMA QUE UMA PECA DEVE TER EM ESTOQUE					
	SET @estqMin = (SELECT p.qt_EstoqueMinimo FROM 
					Peca p WHERE p.cd_UPC = @cdUpcPeca
					);
					
	IF @estqMin > @qt_estocada
		IF NOT EXISTS (SELECT cd_UPC FROM Peca_Requisicao WHERE cd_UPC = @cdUpcPeca)
			INSERT INTO Peca_Requisicao VALUES (@qt_estocada, @estqMin + 10, @cdUpcPeca);
		ELSE
			UPDATE Peca_Requisicao 
			SET qt_emEstoque = @qt_estocada WHERE cd_UPC = @cdUpcPeca;
--FIM DA PROCEDURE
--revisada
--testada

/*
4. Faça um trigger para armazenar em uma tabela chamada 
Historico_Pecas_Excluidas (código, descrição da peça) todas
as peças que foram excluídas da tabela Peças, mais a informação
de qual usuário do sistema realizou a exclusão e em qual data e
hora. Atenção, essa trigger somente excluirá as peças se eles
não tiverem quantidades em estoque . Caso isso aconteça a tabela
chamada TentativasLog (data, operação, código da peça, usuário)
é alimentada com os dados das peças que seriam excluídas.
*/

CREATE TRIGGER trg_ExcluirPeca ON Peca
INSTEAD of delete
as

	begin
		
		IF ( qt_emEstoque = 0 ) 
		BEGIN
			Declare @cdUPC int, @dspeca char(15), @dataexc date, @usua int, @cd_ope int, @cd_tent int;
			
			IF exists (Select * From Deleted)
			begin
			
				Set @cdUPC = (select cd_UPC from Peca deleted);
				Set @dataexc = GETDATE();
				Set @usua = (select cd_Usuario from Usuario U where U.isLogado = 1);
				Set @dspeca = (select ds_Peca from Peca where cd_UPC = @cdUPC);
		
				Insert HistoricoPecas_Excluidas values (@usua, @dspeca, @dataexc, @cdUPC);
			end
		ELSE
		
			Print '- ESTOQUE MAIOR QUE 0 -';
			Set @cd_tent = (select cd_Tentativa from TentativasLog) + 1;
			Set @cdUPC = (select cd_UPC from Peca deleted);
			Set @usua = (select cd_Usuario from Usuario); 
			SET @dataexc = GETDATE();
			Set @cd_ope = (select ds_Operacao from Operacoes where cd_Operacao = 2);
		
			INSERT TentativasLog values (@cd_tent, @usua, @dataexc, @cd_ope, @cdUPC)
		
		END
	End
	



/*
5. Faça um trigger para armazenar em uma tabela chamada 
Histórico_Precos (código da peça, data, preço antigo, preço novo, usuário) 
as alterações de preços ocorridas nas peças cadastradas na tabela Peças. 
Atenção, esse trigger somente deverá ser disparado quando houver alteração no atributo 
valor da peça da tabela .
*/

CREATE TRIGGER trg_AlteracaoPrecoPeca ON Peca
FOR UPDATE as

	begin

		Declare @cdUPC int, @dataupd date, @vl_old money, @vl_new money, @usua int, @cd_alte int;
		
		--IF Exists (Select * From Inserted)
		
			Set @cdUPC = (select cd_UPC from Peca inserted);
			Set @dataupd = getdate();
			Set @vl_old = (select vl_Peca from Peca);
			Set @vl_new = (select vl_Peca from inserted);
			Set @usua = (select cd_Usuario from Usuario WHERE isLogado = 1); 
			Set @cd_alte = (select cd_AlteracaoPreco from Historico_Precos) + 1 ;
		
			Insert Historico_Precos values (@cd_alte, @vl_old, @vl_new, @dataupd, @cdUPC, @usua);
			--Update Peca set vl_Peca = @vl_new where cd_UPC = @cdUPC;
	
		
			Print '- ALTERACAO REGISTRADA -';
End
--revisada
