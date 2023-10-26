library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PKG.all;


entity CPU_PC is
    generic(
        mutant: integer := 0
    );
    Port (
        -- Clock/Reset
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- Interface PC to PO
        cmd    : out PO_cmd ;
        status : in  PO_status
    );
end entity;

architecture RTL of CPU_PC is
    type State_type is (
        S_Error,
        S_Init,
        S_Pre_Fetch,
        S_Fetch,
        S_Decode,
        S_LUI,
        S_ADDI,
        S_ADD,
        S_SUB,
        S_SLL,
        S_SLLI,
        S_SRA,
        S_SRAI,
        S_AUIPC,
        S_BEQ,
        S_SLT,
        S_SLTI,
        S_ORI,
        S_OR,
        S_AND,
        S_ANDI,
        S_XOR,
        S_XORI,
        S_LW1,
        S_LW2,
        S_LW3,
        S_SW1,
        S_SW2,
        S_JAL,
        S_BLT,
        S_BGE,
        S_BGEU,
        S_BLTU,
        S_BNE,
        S_JALR,
        S_SRL,
        S_SRLI,
        S_SLTU,
        S_SLTIU,
        S_LB,
        S_LH1,
        S_LH2,
        S_LH3,
        S_LB1,
        S_LB2,
        S_LB3,
        S_SB1,
        S_SB2,
        S_SH1,
        S_SH2,
        S_LBU1,
        S_LBU2,
        S_LBU3,
        S_LHU1,
        S_LHU2,
        S_LHU3,
        S_CSRRW,
        S_CSRRS
    );

    signal state_d, state_q : State_type;


    begin

        FSM_synchrone : process(clk)
        begin
            if clk'event and clk='1' then
                if rst='1' then
                    state_q <= S_Init;
                else
                    state_q <= state_d;
                end if;
            end if;
        end process FSM_synchrone;
    
        FSM_comb : process (state_q, status)
        begin
    
            -- Valeurs par défaut de cmd à définir selon les préférences de chacun
            cmd.ALU_op            <= UNDEFINED;
            cmd.LOGICAL_op        <= UNDEFINED;
            cmd.ALU_Y_sel         <= UNDEFINED;
    
            cmd.SHIFTER_op        <= UNDEFINED;
            cmd.SHIFTER_Y_sel     <= UNDEFINED;
    
            cmd.RF_we             <= '0';
            cmd.RF_SIZE_sel       <= UNDEFINED;
            cmd.RF_SIGN_enable    <= '0';
            cmd.DATA_sel          <= UNDEFINED;
    
            cmd.PC_we             <= '0';
            cmd.PC_sel            <= UNDEFINED;
    
            cmd.PC_X_sel          <= UNDEFINED;
            cmd.PC_Y_sel          <= UNDEFINED;
    
            cmd.TO_PC_Y_sel       <= UNDEFINED;
    
            cmd.AD_we             <= '0';
            cmd.AD_Y_sel          <= UNDEFINED;
    
            cmd.IR_we             <= '0';
    
            cmd.ADDR_sel          <= UNDEFINED;
            cmd.mem_we            <= '0';
            cmd.mem_ce            <= '0';
    
            cmd.cs.CSR_we            <= UNDEFINED;
    
            cmd.cs.TO_CSR_sel        <= UNDEFINED;
            cmd.cs.CSR_sel           <= UNDEFINED;
            cmd.cs.MEPC_sel          <= UNDEFINED;
    
            cmd.cs.MSTATUS_mie_set   <= '0';
            cmd.cs.MSTATUS_mie_reset <= '0';
    
            cmd.cs.CSR_WRITE_mode    <= UNDEFINED;
    
            state_d <= state_q;
    
            case state_q is
    
            when S_Error =>
                -- Etat transitoire en cas d'instruction non reconnue 
                -- Aucune action
                state_d <= S_Init;

            when S_Init =>
                -- PC <- RESET_VECTOR
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_rstvec;
                state_d <= S_Pre_Fetch;

            when S_Pre_Fetch =>
                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d      <= S_Fetch;

            when S_Fetch =>
                -- IR <- mem_datain
                cmd.IR_we <= '1';
                state_d <= S_Decode;

            
            when S_Decode =>
            -- On peut aussi utiliser un case, ...
            -- et ne pas le faire juste pour les branchements et auipc
                if status.IR(6 downto 0) = "0110111" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LUI;
                elsif status.IR(6 downto 0) = "0010011" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    if status.IR(14 downto 12) = "110" then
                        state_d <= S_ORI;
                    elsif status.IR(14 downto 12)="100" then
                        state_d <= S_XORI;
                    elsif status.IR(14 downto 12) = "001" then
                        state_d <= S_SLLI;
                    elsif status.IR(14 downto 12) = "010" then 
                        state_d <= S_SLTI;
                    elsif status.IR(14 downto 12) ="101" then
                        if status.IR(30)='1' then
                            state_d <= S_SRAI;
                        else
                            state_d <= S_SRLI;
                        end if;
                    elsif status.IR(14 downto 12) = "111" then
                        state_d <= S_ANDI;
                    elsif status.IR(14 downto 12)= "011" then 
                        state_d <= S_SLTIU;
                    else
                        state_d <= S_ADDI;
                    end if;
                elsif status.IR(6 downto 0) = "0110011" then 
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    if status.IR(14 downto 12) = "000" then
                        if status.IR(31 downto 25)="0000000" then
                            state_d <= S_ADD;
                        else
                            state_d <= S_SUB;
                        end if;
                    elsif status.IR(14 downto 12)="100" then
                        state_d <= S_XOR;   
                    elsif status.IR(14 downto 12) = "010" then
                        state_d <= S_SLT;
                    elsif status.IR(14 downto 12) = "110" then 
                        state_d <= S_OR;
                    elsif status.IR(14 downto 12) = "111" then 
                        state_d <= S_AND;
                    elsif status.IR(14 downto 12) = "101" then
                        if status.IR(30)='1' then
                            state_d <= S_SRA;
                        else
                            state_d <= S_SRL;
                        end if;
                    elsif status.IR(14 downto 12)="011" then
                        state_d <= S_SLTU;
                    else 
                        state_d <= S_SLL;
                    end if;
                elsif status.IR(6 downto 0) ="0010111" then
               		state_d <= S_AUIPC;
                elsif status.IR(6 downto 0)="1100011" then
                    if status.IR(14 downto 12)="101" then
                        state_d <= S_BGE;
                    elsif status.IR(14 downto 12)="100" then
                        state_d <= S_BLT;
                    elsif status.IR(14 downto 12)="111" then 
                        state_d <= S_BGEU;
                    elsif status.IR(14 downto 12)="110" then 
                        state_d <= S_BLTU;
                    elsif status.IR(14 downto 12)="001" then 
                        state_d <= S_BNE;
                    else
                        state_d <= S_BEQ;
                    end if;
                elsif status.IR(6 downto 0)="1101111" then
                    state_d <= S_JAL;
                elsif status.IR(6 downto 0)="1100111" then
                    state_d <= S_JALR;
                elsif status.IR(6 downto 0)="0000011" then 
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    if status.IR(14 downto 12)="001" then
                        state_d<=S_LH1;
                    elsif status.IR(14 downto 12)="101" then
                        state_d <= S_LHU1;
                    elsif status.IR(14 downto 12)="000" then
                        state_d <= S_LB1;
                    elsif status.IR(14 downto 12)="100" then
                        state_d <= S_LBU1;
                    else
                        state_d <= S_LW1;
                    end if;
                
                elsif status.IR(6 downto 0)="0100011" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    if status.IR(14 downto 12)="000" then
                        state_d <= S_SB1;
                    elsif status.IR(14 downto 12)="001" then
                        state_d <= S_SH1;
                    else
                        state_d <= S_SW1;
                    end if;
                elsif status.IR(6 downto 0)="1110011" then
                        cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                        cmd.PC_sel <= PC_from_pc;
                        cmd.PC_we <= '1';
                    if status.IR(14 downto 12)="001" then
                        cmd.cs.CSR_WRITE_mode <= WRITE_mode_simple;
                        cmd.cs.TO_CSR_sel <= TO_CSR_from_rs1;
                        state_d <= S_CSRRW;
                    elsif status.IR(14 downto 12)="010" then
                        cmd.cs.CSR_WRITE_mode <= WRITE_mode_set;
                        cmd.cs.TO_CSR_sel <= TO_CSR_from_rs1;
                        state_d <= S_CSRRS;
                    end if;
                else
                    state_d <= S_Error; -- Pour détecter les ratés du décodage
                end if;




---------- Instructions de décalages ----------


            when S_SLL =>
                cmd.RF_we <= '1'; 
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2; 
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Fetch;



            when S_SLLI =>
                cmd.RF_we <= '1'; 
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh; 
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Fetch;


            when S_SRA =>
                cmd.RF_we <= '1'; 
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2; 
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Fetch;


            when S_SRAI =>
                cmd.RF_we <= '1'; 
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh; 
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Fetch;


            when S_SRL =>
                cmd.RF_we <= '1'; 
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2; 
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Fetch;


            when S_SRLI =>
                cmd.RF_we <= '1'; 
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh; 
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Fetch;
            
            
            when S_SLT => 
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Fetch;


            when S_SLTI => 
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Fetch;
            

            when S_SLTU =>
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.RF_we <='1';
                cmd.DATA_sel <= DATA_from_slt;
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d <= S_Fetch;


            when S_SLTIU => 
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.RF_we <='1';
                cmd.DATA_sel <= DATA_from_slt;
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d <= S_Fetch;



---------- Instructions avec immediat de type U ----------


            when S_LUI =>
                -- rd <- ImmU + 0
                cmd.PC_X_sel <= PC_X_cst_x00;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- lecture mem[PC]cmd.DATA_sel <=
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_we<='0';
                cmd.mem_ce<='1';
                state_d <= S_Fetch;
            


            when S_AUIPC =>
                cmd.RF_we <= '1'; 
                cmd.DATA_sel <= DATA_from_pc;
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1'; 
                state_d <= S_Pre_Fetch; 






---------- Instructions arithmétiques et logiques ----------
            
            when S_ADDI =>
                cmd.RF_we <= '1';
                cmd.ALU_op <= ALU_plus;
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.DATA_sel <= DATA_from_alu;
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Fetch;


            when S_ADD =>
                cmd.RF_we <= '1';
                cmd.ALU_op <= ALU_plus;
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.DATA_sel <= DATA_from_alu;
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Fetch;


            when S_SUB =>
                cmd.RF_we <= '1';
                cmd.ALU_op <= ALU_minus;
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.DATA_sel <= DATA_from_alu;
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Fetch;


           when S_ORI =>
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_FETCH;


            when S_OR =>
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_FETCH;


            when S_AND =>
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_FETCH;


            when S_ANDI =>
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_FETCH;


            when S_XORI =>
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_FETCH;


            when S_XOR =>
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_FETCH;




            

---------- Instructions de saut ----------


            when S_JAL =>
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.TO_PC_Y_sel <= TO_PC_Y_immJ;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                cmd.RF_we <= '1';
                state_d <= S_Pre_Fetch;


            when S_JALR =>
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.PC_sel <= PC_from_alu;
                cmd.ALU_op <= ALU_plus;
                cmd.PC_we <= '1';
                cmd.RF_we <= '1';
                cmd.AD_we <= '1';
                state_d <= S_Pre_Fetch;


            when S_BEQ =>
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.PC_we <= '1';
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_slt;
                cmd.PC_sel <= PC_from_pc;
                if (status.JCOND) then 
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                end if;
                state_d <= S_Pre_Fetch;


            when S_BGE =>
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.PC_we <= '1';
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_slt;
                cmd.PC_sel <= PC_from_pc;
                if (status.JCOND) then 
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                end if;
                state_d <= S_Pre_Fetch;


            when S_BLT =>
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.PC_we <= '1';
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_slt;
                cmd.PC_sel <= PC_from_pc;
                if (status.JCOND) then 
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                end if;
                state_d <= S_Pre_Fetch;


            when S_BLTU =>
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.PC_we <= '1';
                cmd.RF_we <= '0';
                
                if (status.JCOND) then 
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                end if;
                cmd.PC_sel <= PC_from_pc;
                state_d <= S_Pre_Fetch;


            when S_BGEU =>
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.PC_we <= '1';
                cmd.RF_we <= '0';
                
                if (status.JCOND) then 
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                end if;
                cmd.PC_sel <= PC_from_pc;
                state_d <= S_Pre_Fetch;


            when S_BNE =>
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.PC_we <= '1';
                cmd.RF_we <= '0';
                
                if (status.JCOND) then 
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                end if;
                cmd.PC_sel <= PC_from_pc;
                state_d <= S_Pre_Fetch;






---------- Instructions de sauvegarde en mémoire ----------

            when S_SW1 =>
                cmd.AD_Y_sel <= AD_Y_immS;
                cmd.AD_we <= '1';
                state_d <= S_SW2;
            when S_SW2 =>
                cmd.mem_ce <= '1';
                cmd.mem_we <= '1';
                cmd.RF_SIGN_enable <= '1';
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.RF_SIZE_sel <= RF_SIZE_word;
                state_d <= S_Pre_Fetch;


            when S_SB1 =>
                cmd.AD_Y_sel <= AD_Y_immS;
                cmd.AD_we <= '1';
                state_d <= S_SB2;
            when S_SB2 =>
                cmd.mem_ce <= '1';
                cmd.mem_we <= '1';
                cmd.RF_SIGN_enable <= '1';
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.RF_SIZE_sel <= RF_SIZE_byte;
                state_d <= S_Pre_Fetch;


            when S_SH1 =>
                cmd.AD_Y_sel <= AD_Y_immS;
                cmd.AD_we <= '1';
                state_d <= S_SH2;
            when S_SH2 =>
                cmd.mem_ce <= '1';
                cmd.mem_we <= '1';
                cmd.RF_SIGN_enable <= '1';
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.RF_SIZE_sel <= RF_SIZE_half;
                state_d <= S_Pre_Fetch;





                
---------- Instructions de chargement à partir de la mémoire ----------
            

            when S_LBU1 =>
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                state_d <= S_LBU2;
            when S_LBU2 =>
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_LBU3;
            when S_LBU3 =>
                cmd.RF_SIGN_enable <= '0';
                cmd.RF_SIZE_sel <= RF_SIZE_byte;
                cmd.DATA_sel <=  DATA_from_mem;
                cmd.RF_we <= '1';
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Pre_Fetch;



            when S_LHU1 =>
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                state_d <= S_LHU2;
            when S_LHU2 =>
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_LHU3;
            when S_LHU3 =>
                cmd.RF_SIGN_enable <= '0';
                cmd.RF_SIZE_sel <= RF_SIZE_half;
                cmd.DATA_sel <=  DATA_from_mem;
                cmd.RF_we <= '1';
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Pre_Fetch;



            when S_LW1 =>
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                state_d <= S_LW2;
            when S_LW2 =>
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_LW3;
            when S_LW3 =>
                cmd.RF_SIGN_enable <= '1';
                cmd.RF_SIZE_sel <= RF_SIZE_word;
                cmd.DATA_sel <=  DATA_from_mem;
                cmd.RF_we <= '1';
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Pre_Fetch;



            when S_LH1 =>
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                state_d <= S_LH2;
            when S_LH2 =>
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_LH3;
            when S_LH3 =>
                cmd.RF_SIGN_enable <= '1';
                cmd.RF_SIZE_sel <= RF_SIZE_half;
                cmd.DATA_sel <=  DATA_from_mem;
                cmd.RF_we <= '1';
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Pre_Fetch;



            when S_LB1 =>
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                state_d <= S_LB2;
            when S_LB2 =>
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_LB3;
            when S_LB3 =>
                cmd.RF_SIGN_enable <= '1';
                cmd.RF_SIZE_sel <= RF_SIZE_byte;
                cmd.DATA_sel <=  DATA_from_mem;
                cmd.RF_we <= '1';
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_Pre_Fetch;


                
---------- Instructions d'accès aux CSR ----------


            ---!!! CSRRWS et CSRRS ne fonctionnent pas ( non présentes dans sequence_tag)  !!!----
           
            when S_CSRRW =>
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_csr;
                if (status.IR(31 downto 20) = "001100000000") then
                    cmd.cs.CSR_sel <= CSR_from_mstatus;
                    cmd.cs.CSR_we <= CSR_mstatus;
                elsif (status.IR(31 downto 20) = "001101000100") then
                    cmd.cs.CSR_sel <= CSR_from_mip;
                elsif (status.IR(31 downto 20) = "001101000010") then
                    cmd.cs.CSR_sel <= CSR_from_mcause;
                elsif (status.IR(31 downto 20) = "001100000101") then
                    cmd.cs.CSR_sel <= CSR_from_mtvec;
                    cmd.cs.CSR_we <= CSR_mtvec;
                elsif (status.IR(31 downto 20) = "001100000100") then
                    cmd.cs.CSR_sel <= CSR_from_mie;
                    cmd.cs.CSR_we <= CSR_mie;
                elsif (status.IR(31 downto 20) = "001101000001") then
                    cmd.cs.CSR_sel <= CSR_from_mepc;
                    cmd.cs.CSR_we <= CSR_mepc;
                    cmd.cs.MEPC_sel <= MEPC_from_csr;
                else
                    state_d <= S_Error;
                end if;
                state_d <= S_PRE_FETCH;
            

            when S_CSRRS =>
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_csr;
                if (status.IR(31 downto 20) = "001100000000") then
                    cmd.cs.CSR_sel <= CSR_from_mstatus;
                    cmd.cs.CSR_we <= CSR_mstatus;
                elsif (status.IR(31 downto 20) = "001101000100") then
                    cmd.cs.CSR_sel <= CSR_from_mip;
                elsif (status.IR(31 downto 20) = "001101000010") then
                    cmd.cs.CSR_sel <= CSR_from_mcause;
                elsif (status.IR(31 downto 20) = "001100000101") then
                    cmd.cs.CSR_sel <= CSR_from_mtvec;
                    cmd.cs.CSR_we <= CSR_mtvec;
                elsif (status.IR(31 downto 20) = "001100000100") then
                    cmd.cs.CSR_sel <= CSR_from_mie;
                    cmd.cs.CSR_we <= CSR_mie;
                elsif (status.IR(31 downto 20) = "001101000001") then
                    cmd.cs.CSR_sel <= CSR_from_mepc;
                    cmd.cs.CSR_we <= CSR_mepc;
                    cmd.cs.MEPC_sel <= MEPC_from_csr;
                else
                    state_d <= S_Error;
                end if;
                state_d <= S_Pre_Fetch;

            when others => null;
        end case;

    end process FSM_comb;

end architecture;
