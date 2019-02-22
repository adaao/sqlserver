/*PROCEDURES E TRIGGERS*/

/*
1-Elabore uma procedure para efetuar o recebimento do estoque de uma pe�a. 
A procedure dever� receber tr�s par�metros de 
entrada (pedido, c�digo da pe�a e quantidade de entrada). 
Al�m de gerar uma tabela de PedidoPe�a para armazenar as pe�as de cada pedido, 
deve tamb�m atualizar o quantidade de estoque da tabela de Pe�as
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
2. Elabore uma procedure para fazer uma c�pia dos dados de um pedido de um determinado m�s e ano,
 em uma tabela denominada Pedidos_finalizados, e todos os seus itens de PedidoPe�a
 sejam armazenados em uma tabela denominada PedidosPe�as_finalizados. Ap�s a c�pia,
 o pedido e seus itens ser�o exclu�dos.
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
		PRINT 'N�o existem pedidos do ano ou m�s solicitado'
END
--fim da procedure
--revisada
--testada




/*
3. Elabore uma procedure para efetuar a compara��o entre estoque m�nimo e estoque atual de uma pe�a.
 Caso o estoque esteja abaixo do estoque m�nimo, ser� armazenado em uma tabela 
 pe�a_requisicao (codigo, qtd em estoque, qtd a comprar). 
 Se for necess�rio, inclua o atributo estoque m�nimo na tabela de pe�as.
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
4. Fa�a um trigger para armazenar em uma tabela chamada 
Historico_Pecas_Excluidas (c�digo, descri��o da pe�a) todas
as pe�as que foram exclu�das da tabela Pe�as, mais a informa��o
de qual usu�rio do sistema realizou a exclus�o e em qual data e
hora. Aten��o, essa trigger somente excluir� as pe�as se eles
n�o tiverem quantidades em estoque . Caso isso aconte�a a tabela
chamada TentativasLog (data, opera��o, c�digo da pe�a, usu�rio)
� alimentada com os dados das pe�as que seriam exclu�das.
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
5. Fa�a um trigger para armazenar em uma tabela chamada 
Hist�rico_Precos (c�digo da pe�a, data, pre�o antigo, pre�o novo, usu�rio) 
as altera��es de pre�os ocorridas nas pe�as cadastradas na tabela Pe�as. 
Aten��o, esse trigger somente dever� ser disparado quando houver altera��o no atributo 
valor da pe�a da tabela .
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
