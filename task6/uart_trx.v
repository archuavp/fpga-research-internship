module uart_tx_8n1 (
  input clk,
  input [7:0] txbyte,
  input senddata,
  output reg txdone,
  output tx
);

  // Parameters
  parameter STATE_IDLE    = 8'd0;
  parameter STATE_STARTTX = 8'd1;
  parameter STATE_TXING   = 8'd2;
  parameter STATE_TXDONE  = 8'd3;

  // State variables
  reg [7:0] state = STATE_IDLE;
  reg [7:0] buf_tx = 8'b0;
  reg [3:0] bits_sent = 4'b0;
  reg txbit = 1'b1;

  assign tx = txbit;

  always @(posedge clk) begin
    case (state)
      STATE_IDLE: begin
        txbit <= 1'b1; // idle line high
        txdone <= 1'b0;
        bits_sent <= 4'b0;

        if (senddata == 1'b1) begin
          buf_tx <= txbyte;
          state <= STATE_STARTTX;
        end
      end

      STATE_STARTTX: begin
        txbit <= 1'b0; // start bit
        state <= STATE_TXING;
      end

      STATE_TXING: begin
        txbit <= buf_tx[0]; // send LSB
        buf_tx <= buf_tx >> 1;
        bits_sent <= bits_sent + 1;

        if (bits_sent == 4'd7) begin
          state <= STATE_TXDONE;
        end
      end

      STATE_TXDONE: begin
        txbit <= 1'b1; // stop bit
        txdone <= 1'b1;
        state <= STATE_IDLE;
      end

      default: state <= STATE_IDLE;
    endcase
  end

endmodule