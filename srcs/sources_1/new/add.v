// 2 by 2 matrix multiplier
// Inputs are named A and B and output is named C
// Each matrix has 4 elements 8 bits wide. Thus the inputs are 4*8 = 32 bits long

module matrix_mult1(

    input reset, // active low reset
    input enable, // High throughout the process
    input [8191:0] A,
    input [8191:0] B,
    input [7:0] Ax,
    input [7:0] Ay,
    input [7:0] Bx,
    input [7:0] By,
    output reg[8191:0] C,
    output reg done // High indcates that the process is complete
    );

// temporary registers 
real  matrixA [][];
real  matrixB [][];
real  matrixC [][];

integer i,j,k; // for the loops
reg first_cycle; // indicates first clock cycle after enable high
reg end_mult; //goes high when multiplication is completed
reg signed [63:0] temp; // stores the product of multiplication

reg [2:0]state //state indication

parameter s_init = 3'b000;

always @(posedge clk) begin
    case(state)
        s_init:
        begin
            matrixA = new[Ax][Ay]; 
        end
end
//parameter 
/*
always @(posedge clock, negedge reset)
begin
    if(reset == 0)begin  // active low reset
        i = 0;
        j = 0;
        k = 0;
        temp = 0;
        first_cycle = 1;
        end_mult = 0;
        done = 0;
        // initialization of matrix elements
        for(i=0; i<=1; i=i+1) begin
            for(j=0; j<=1; j=j+1) begin
            matrixA[i][j] = 32'd0;
            matrixB[i][j] = 32'd0;
            matrixC[i][j] = 32'd0;
            
        end
     end
    end

    else begin
        if(enable == 1)
            if(first_cycle == 1) begin
            // first cycle converts 1-D array inputs to 2-D matices
            for(i = 0;i<=1; i = i+1) begin
                for(j = 0;j<=1; j = j+1) begin
                    matrixA[i][j] = A[(i*2+j)*8+:8];
                    matrixB[i][j] = B[(i*2+j)*8+:8];
                    matrixC[i][j] = 8'd0;
                end
            end
            // re-initialisation of registers
            first_cycle = 0;
            end_mult = 0;
            i = 0;
            j = 0;
            k = 0;
        end
        else if(end_mult == 0) begin // if multiplication hasn't ended keep multiplying
            temp = matrixA[i][k]*matrixB[k][j];
            matrixC[i][j] = matrixC[i][j] + temp[7:0]; // lower half of the product is accumulatively added to form the result
        if(k==1) begin
            k =0;
            if(j == 1) begin
                j = 0;
                if (i == 1)begin
                    i = 0;
                    end_mult = 1;
                end
                else
                    i = i +1;
            end
            else
                j = j + 1;
        end
        else
            k = k + 1;
        end
        else if(end_mult == 1) begin 
        // conversion of 2-D matrix into 1-D array after the termination of the multiplication
            for(i=0; i<=1; i=i+1) begin
                for(j=0; j<=1; j=j+1) begin
                    C[(i*2+j)*8+:8] = matrixC[i][j];
                end
            end
            done = 1;
        end
    end 
end    
*/    
endmodule