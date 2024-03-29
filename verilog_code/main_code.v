module semi_final0(clk, rst,stop_start, stop_stop, seg_data, seg_com,seg_data2,h_adjust,m_adjust, s_adjust,
led,led2,menu,smotor,servo,piezo,s_adjust2, m_adjust2,h_adjust2);
input clk ,rst,h_adjust,m_adjust,s_adjust,stop_start, stop_stop;
input menu;
input s_adjust2, m_adjust2,h_adjust2;

output reg [7:0] seg_data;
output reg [7:0] seg_com;
output reg [7:0] seg_data2;
output reg [3:0] led = 4'b1000;
output reg[3:0] led2 = 4'b1000;
output reg [3:0] smotor;
output reg piezo;
output reg servo;

wire [7:0] seg_s_ten, seg_s_one;
wire [7:0] seg_m_ten, seg_m_one;
wire [7:0] seg_h_ten, seg_h_one;
wire [7:0] seg_m_m, seg_m_mm;
wire h_up, m_up, s_up;
wire h_down, m_down, s_down;
wire menu_w;
wire s_start, s_stop;

reg [20:0] cnt;
reg [3:0] sec [1:0];
reg [3:0] min [1:0];
reg [3:0] hour [1:0];
reg [3:0] m_min; 
reg [3:0] m_sec;
reg [3:0] count;
reg [1:0] state = 2'b00;
reg flag, s_flag;
reg [7:0] day;
reg alarm, alarm_end;
reg motor_clk;
reg [1:0] motor_state = 0;
reg piezo_clk;
reg [20:0]piezo_cnt;
reg[11:0] piezo_half;
reg[5:0] melody = 0;
reg [2:0] selection;
reg [3:0] rhy;
reg [7:0] game_number;
reg [3:0] game_time[5:0];
reg game_flag;
reg [20:0] piezo_time;
reg [9:0] random_case;
reg [1:0] led_count = 2'b00;

integer piezo_control= 0;
integer clk_control=0; 
integer tmp, motor_cnt;
integer a = 0;

reg motor_cnt2;

always@(posedge clk) begin
    if(rst) begin
       count <= 0;
    end
    else begin
        if(count ==8) count <= 0;
        else count <= count +1;
    end
end

always@(posedge clk) begin 
    if(rst) seg_com = 8'b0111_1111;
    else begin
        case (count)
             3'b000 : seg_com=8'b1111_1011; 
             3'b001 : seg_com=8'b1111_0111;
             3'b010 : seg_com=8'b1110_1111;
             3'b011 : seg_com=8'b1101_1111;
             3'b100 : seg_com=8'b1011_1111;
             3'b101 : seg_com= 8'b0111_1111;
             3'b110 : seg_com =8'b1111_1101;
             3'b111: seg_com = 8'b1111_1110;
        endcase
    end
end
always@(posedge clk) begin
    if(rst) seg_data = 8'b1111_1100;
    else begin
        case (count)
        3'b000 : seg_data = seg_s_one;
        3'b001: seg_data =seg_s_ten;
        3'b010: seg_data = seg_m_one;
        3'b011: seg_data = seg_m_ten;
        3'b100: seg_data = seg_h_one;
        3'b101: seg_data = seg_h_ten;
        3'b110: seg_data =  seg_m_m;
        3'b111: seg_data = seg_m_mm;
        
        endcase 
    end
end

seg_decoder1 u1(sec[0], seg_s_one);
seg_decoder u2(sec[1], seg_s_ten);
seg_decoder1 u3(min[0], seg_m_one);
seg_decoder u4(min[1], seg_m_ten);
seg_decoder1 u5(hour[0], seg_h_one);
seg_decoder u6(hour[1], seg_h_ten);
seg_decoder u7(m_min, seg_m_m);
seg_decoder u8(m_sec ,seg_m_mm);
//switch connect
// rst ==1; 
switch s1 (clk,rst,h_adjust,h_up); //시 조정 4번 sec[0[
switch s2 (clk,rst,m_adjust,m_up); //분 조정 5번 sec[1]
switch s3 (clk,rst,s_adjust,s_up); //초 조정 6번 min[0]
switch s4 (clk,rst,menu,menu_w); // 메뉴 조정 3번 
switch s5 (clk,rst,stop_start,s_start); // 메뉴 조정 *번 
switch s6 (clk,rst,stop_stop,s_stop); // 메뉴 조정 #번 
switch s7 (clk,rst,h_adjust2,h_down); //시 조정 7번 min[1[
switch s8 (clk,rst,m_adjust2,m_down); //분 조정 8번 hour[1]
switch s9 (clk,rst,s_adjust2,s_down); //초 조정 9번 hour[0]
//메뉴 조정
always@(posedge clk) begin 
    if(menu_w ==1) begin
        state <= state +1;
    end
end
//led 조정
always@(posedge clk) begin
    case (state) 
        2'b00 : led= 4'b1000; //정상 시계 + 조정가능
        2'b01 : led = 4'b0100; // 스톱와치
        2'b10 : led = 4'b0010; // 타이머
        2'b11 : led = 4'b0001; //리듬게임
    endcase
end
//led2_count 조정
always@(posedge clk)begin
    if(rst) led_count =0;
    else begin
        if(cnt==99999)begin
            led_count = led_count +1;
        end
    end
end
//led2 조정
always@(posedge clk)begin
    if(rst) led2 = 4'b1000;
    else begin
        if(state==2'b00)begin
            case(led_count)
                2'b00 : led2 = 4'b1000;
                2'b01 : led2 = 4'b0100;
                2'b10: led2  = 4'b0010;
                2'b11 : led2 = 4'b0001;
            endcase
        end
        else if(state==2'b01& s_flag==1 )begin
            if(rst) led2 = 4'b1000;
            case(led_count)
                2'b00 : led2 = 4'b1000;
                2'b01 : led2 = 4'b0100;
                2'b10: led2  = 4'b0010;
                2'b11 : led2 = 4'b0001;
            endcase
        end
        else if (state==2'b10 & alarm==1)begin
            if(rst) led2 = 4'b1000;
            case(led_count)
                2'b00 : led2 = 4'b1000;
                2'b01 : led2 = 4'b0100;
                2'b10: led2  = 4'b0010;
                2'b11 : led2 = 4'b0001;
            endcase
        end
        else if (state==2'b10 & alarm_end==1)begin
            if(rst) led2 = 4'b1000;
            case(led_count)
                2'b00 : led2 = 4'b1000;
                2'b01 : led2 = 4'b0100;
                2'b10: led2  = 4'b0010;
                2'b11 : led2 = 4'b0001;
            endcase
        end
        else if(state==2'b11)begin
            led2 = 4'b0000;
        end
    end
end
//cnt 
always@(posedge clk) begin
    if (rst) cnt <= 0;
     else begin
         if(state==2'b00)begin //시간 나타내기
                if(cnt==99999) cnt<=0;
                else cnt <= cnt+1;
         end
         else if(state==2'b01)begin      //스탑와치
                if(rst) begin 
                    cnt <= 0;
                end
                else if(s_flag==1) begin
                    if(cnt==99999) cnt<=0;
                    else cnt <= cnt+1;
                end
                else  begin
                    cnt<=cnt;
                end 
         end
         else if(state==2'b10)begin
            if(rst) begin 
                        cnt<=0;
                    end
            else if(alarm==1) begin
                if(cnt==99999) cnt<=0;
                else cnt <= cnt+1;
            end
            else if(alarm_end==1) begin
                if(cnt==99999) cnt<=0;
                else cnt <= cnt+1;
            end
            else begin
                cnt<=0;
            end
         end
         else if(state==2'b11)begin
            if(rst)  cnt<=0;
            else begin
                if(game_flag==0) cnt<=0;
                else begin
                    if(game_flag==1)begin
                        if(cnt==99999) begin
                            cnt <= 0;
                        end
                        else cnt<=cnt+1;
                    end
                end
            end
         end
     end
end
//m_sec
always@(posedge clk)begin
    if(rst) m_sec = 0;
    else begin
        if(state==2'b00) begin
            if((cnt%1000)==0) begin
                 if(m_sec ==9) begin
                      m_sec <= 0;
                     end
                 else begin
                     m_sec <= m_sec +1;
                     end
                 end
         end
         else if(state==2'b01)begin
            if(rst) m_sec =0;
            else if(s_flag==1)begin
                if(cnt%1000 ==0) begin
                    if(m_sec ==9) begin
                        m_sec <= 0;
                    end
                 else begin
                        m_sec <= m_sec +1;
                 end
              end
            end
            else m_sec <= m_sec;
         end   
         else if(state==2'b10)begin //스탑워치
             if (rst) m_sec <=0;
             else if(alarm==0)begin
                m_sec <=0;
             end
             else begin
                 if(cnt%1000 ==0) begin
                     if(m_sec ==9) begin
                          m_sec <= 0;
                     end
                     else begin
                            m_sec <= m_sec +1;
                         end
                  end
              end
         end
         else if(state==2'b11)begin
            if(rst) m_sec<=4'b1010;
            else begin
                m_sec <= 4'b1010;
            end
         end
        end
end
// m_min
always@(posedge clk) begin
    if(rst) m_min =0;
    else begin
        if(state==2'b00) begin
            if(cnt%10000 ==0) begin
                 if(m_min ==9) begin
                      m_min <= 0;
                     end
                 else begin
                     m_min <= m_min +1;
                     end
                 end
         end
         else if(state==2'b01)begin
            if(rst) m_min =0;
            else if(s_flag==1)begin
                if(cnt%10000 ==0) begin
                    if(m_min ==9) begin
                        m_min <= 0;
                    end
                 else begin
                        m_min <= m_min +1;
                 end
              end
            end
            else m_min <= m_min;
         end   
         else if(state==2'b10)begin //스탑워치
             if (rst) m_min <=0;
             else if(alarm==0)begin
                m_min <=0;
             end
             else begin
                 if(cnt%10000 ==0) begin
                     if(m_min ==9) begin
                          m_min <= 0;
                     end
                     else begin
                            m_min <= m_min +1;
                         end
                  end
              end
         end
         else if(state==2'b11)begin
            if(rst) m_min<=4'b1010;
            else begin
                m_min <= 4'b1010;
            end
         end
        end
 end
//second 
always@(posedge clk) begin
    if(rst) begin
        sec[0] <=0;
        sec[1] <=0 ;
    end
    else begin
    if(state==00)begin
            if(s_up==1)begin
                if(sec[1]==5 && sec[0]==9)begin
                    sec[1] <=0;
                    sec[0] <=0;
                end
                else begin
                    if(sec[0] ==9) begin
                        sec[0] <=0;
                        sec[1] <= sec[1] +1;
                    end
                    else sec[0] <= sec[0] +1;
                end
            end
            else if (s_down==1)begin
                if(sec[1]==0) begin
                            if(sec[0]==0)begin
                                sec[1] <=5;
                                sec[0]<=9;
                            end
                            else begin
                                sec[0] <= sec[0]-1;
                            end
                  end
                  else begin
                        if(sec[0] ==0)begin
                             sec[1] <= sec[1] -1;
                             sec[0] <= 9;
                        end
                        else sec[0] <= sec[0] -1;
                  end
            end
            else begin
                if(cnt==99999) begin
                    if(sec[1]==5 && sec[0]==9)begin
                        sec[1] <=0;
                        sec[0] <=0;
                    end
                     else begin
                        if(sec[0] ==9) begin
                          sec[0] <=0;
                          sec[1] <= sec[1] +1;
                        end
                        else sec[0] <= sec[0] +1;
                   end
                end
            end   
        end
        
        else if(state==2'b01)begin
            if(rst) begin
                sec[0] <=0;
                sec[1] <=0 ;
            end
            else if(s_flag==1)begin
                if(cnt==99999) begin
                    if(sec[1]==5 && sec[0]==9)begin
                        sec[1] <=0;
                        sec[0] <=0;
                    end
                     else begin
                        if(sec[0] ==9) begin
                          sec[0] <=0;
                          sec[1] <= sec[1] +1;
                        end
                        else sec[0] <= sec[0] +1;
                   end
                end
            end
            else begin
                sec[0] <=sec[0];
                sec[1] <=sec[1];
            end
        end
        
        //state 10
        else if(state==2'b10)begin
            if(rst) begin
                sec[0] <=0;
                sec[1] <= 0;
            end
            else if(s_up==1&& alarm==0) begin
                if(sec[1]==5 && sec[0]==9)begin
                    sec[1] <=0;
                    sec[0] <=0;
                end
                else begin
                    if(sec[0] ==9) begin
                        sec[0] <=0;
                        sec[1] <= sec[1] +1;
                    end
                    else sec[0] <= sec[0] +1;
                end
            end
            else if(alarm==1) begin
                if(cnt==99999) begin
                    if(sec[0]==0)begin
                        if(sec[1]==0) begin
                            if(min[0]==0 &&min[1]==0&&hour[0]==0&hour[1]==0)begin
                                sec[0] <=0;
                                sec[1] <=0;
                            end
                            else begin
                                sec[1] <=5;
                                sec[0]<=9;
                            end
                        end
                        else begin
                            sec[1] <= sec[1] -1;
                            sec[0] <= 9;
                        end
                    end
                    else sec[0] <= sec[0] -1;
                end
            end
            else begin
            
            end
        end
        
        //state 11
        else if(state==2'b11)begin
            if(s_start==1)begin
                sec[0] <= game_number[0];
                sec[1] <= game_number[1];
            end
            else begin
                if(sec[0]==0&sec[1]==0& min[0] ==0 & min[1]==0&hour[0]==0 & hour[1]==0)begin
                    sec[0] <=game_time[0];
                    sec[1]<=game_time[1];
                end
                else if(game_flag==1)begin
                    if(h_up==1) sec[0]<=0;
                    else if(m_up==1) sec[1] <=0;
                end
            end
        end
    end
end

//minutes
always@(posedge clk) begin 
    if(rst) begin 
        min[1] <=0;
        min[0]<=0;
    end
    else begin
        if(state==00) begin
            if(m_up==1) begin
                    if(min[1]==5 && min[0]==9)begin
                        min[1] <=0;
                        min[0] <=0;
                      end
                      else begin
                        if(min[0]==9) begin
                            min[0] <=0;
                            min[1] <= min[1] +1;
                        end
                        else min[0] <= min[0] +1;
                      end
            end
            else if(m_down==1)begin
                    if(hour[0]==0&&hour[1]==0)begin
                        if(min[1]==0)begin
                            if(min[0]==0)begin
                                min[0]<=0;
                                min[1] <=0;
                            end
                            else min[0] <= min[0] -1;
                        end
                        else begin
                            min[1]<=min[1]-1;
                            min[0] <= 9;
                        end
                    end
                    else begin
                        if(min[1]==0)begin
                            if(min[0]==0)begin
                                min[1] <= 5;
                                min[0] <= 9;
                            end
                            else min[0] <= min[0] -1;
                        end
                        else begin
                           if(min[0]==0)begin
                                min[1] <=min[1] -1;
                                min[0] <=9;
                           end
                           else min[0] <= min[0] -1;
                        end
                end
            end
            else begin
                if(cnt==99999 && sec[1]==5 && sec[0]==9) begin
                    if(min[1]==5 && min[0]==9)begin
                        min[1] <=0;
                        min[0] <=0;
                    end
                    else begin
                        if(min[0]==9) begin
                            min[0] <=0;
                            min[1] <= min[1] +1;
                            end
                        else min[0] <= min[0] +1;
                    end
                end
            end
        end
        else if(state==2'b01)begin
            if(rst) begin 
              min[1] <=0;
              min[0]<=0;
            end
            else if(s_flag==1)begin
                if(cnt==99999 && sec[1]==5 && sec[0]==9) begin
                    if(min[1]==5 && min[0]==9)begin
                        min[1] <=0;
                        min[0] <=0;
                    end
                    else begin
                        if(min[0]==9) begin
                            min[0] <=0;
                            min[1] <= min[1] +1;
                            end
                        else min[0] <= min[0] +1;
                    end
                end
            end
            else begin
                min[0]<=min[0];
                min[1]<=min[1];
            end
        end
        
        else if(state==2'b10)begin
            if(rst) begin
                min[0] <=0;
                min[1] <=0;
            end
            else if(alarm==0 && m_up==1)begin
                if(min[1]==5 && min[0]==9)begin
                        min[1] <=0;
                        min[0] <=0;
                end
                else begin
                      if(min[0]==9) begin
                          min[0] <=0;
                          min[1] <= min[1] +1;
                      end
                      else min[0] <= min[0] +1;
                end            
            end
            else if(alarm==1) begin
                if(cnt==99999 && sec[0]==0 & sec[1]==0)begin
                    if(hour[0]==0&&hour[1]==0)begin
                        if(min[1]==0)begin
                            if(min[0]==0)begin
                                min[0]<=0;
                                min[1] <=0;
                            end
                            else min[0] <= min[0] -1;
                        end
                        else begin
                            min[1]<=min[1]-1;
                            min[0] <= 9;
                        end
                    end
                    else begin
                        if(min[1]==0)begin
                            if(min[0]==0)begin
                                min[1] <= 5;
                                min[0] <= 9;
                            end
                            else min[0] <= min[0] -1;
                        end
                        else begin
                           if(min[0]==0)begin
                            min[1] <=min[1] -1;
                            min[0] <=9;
                           end
                           else min[0] <= min[0] -1;
                        end
                    end
                    
                end
            end
        end
        
        // state 11
        else if(state==2'b11)begin
            if(s_start==1)begin
                min[0] <= game_number[2];
                min[1] <= game_number[3];
            end
            else begin
                if(s_stop==1&sec[0]==0&sec[1]==0&min[1]==0&min[0]==0&hour[1]==0&hour[0]==0)begin
                    min[0] <=game_time[2];
                    min[1]<=game_time[3];
                end
                else if(game_flag==1)begin
                    if(s_up==1) min[0]<=0;
                    else if(h_down==1) min[1] <=0;
                    else begin
                        min[0] <=min[0];
                        min[1] <= min[1];
                    end
                end
            end
        end
    end
end

//hours
always@(posedge clk) begin
    if(rst) begin
        hour[0] <= 0;
        hour[1] <=0;
    end
    else begin
    if(state==00) begin
        if(h_up==1) begin 
             if(hour[0]==1 & hour[1] ==1) begin
                    hour[0] <= 0;
                    hour[1] <=0;
                end
                else begin
                    if(hour[0] ==9)begin
                        hour[1] <=hour[1] +1;
                        hour[0] <= 0;
                    end
                    else begin
                        hour[0] <= hour[0] +1;
                    end
                end
        end
        else if(h_down)begin
                if(hour[1]==0)begin
                    if(hour[0]==0)begin
                        hour[0] <=0;
                        hour[1] <=0;
                    end
                    else hour[0] <= hour[0] -1;
                end
                else begin
                    hour[1] <= hour[1] -1;
                    hour[0] <= 9;
                end
        end
        else begin
        if(cnt==99999& min[1]==5& min[0]==9 & sec[1]==5 & sec[0]==9)begin
            if(hour[0]==1 & hour[1] ==1) begin
                hour[0] <= 0;
                hour[1] <=0;
            end
            else begin
                if(hour[0] ==9)begin
                    hour[1] <=hour[1] +1;
                    hour[0] <= 0;
                end
                else begin
                    hour[0] <= hour[0] +1;
                end
            end
        end
    end
    end
    else if(state==2'b01)begin
        if(rst) begin
            hour[0] <= 0;
            hour[1] <=0;
        end
        else if(s_flag==1)begin
            if(cnt==99999& min[1]==5& min[0]==9 & sec[1]==5 & sec[0]==9)begin
                if(hour[0]==1 & hour[1] ==1) begin
                    hour[0] <= 0;
                    hour[1] <=0;
                end
                else begin
                    if(hour[0] ==9)begin
                        hour[1] <=hour[1] +1;
                        hour[0] <= 0;
                    end
                    else begin
                        hour[0] <= hour[0] +1;
                    end
                end
            end
        end
        else begin
            hour[0] <=hour[0];
            hour[1] <=hour[1];
        end
    end
    else if(state==2'b10)begin
        if(alarm==0 & h_up==1)begin
            if(hour[0]==1 & hour[1] ==1) begin
                    hour[0] <= 0;
                    hour[1] <=0;
                end
                else begin
                    if(hour[0] ==9)begin
                        hour[1] <=hour[1] +1;
                        hour[0] <= 0;
                    end
                    else begin
                        hour[0] <= hour[0] +1;
                    end
              end
        end
        else if(alarm==1)begin
            if(cnt==99999 & sec[0]==0 &sec[1]==0 & min[0]==0& min[1]==0)begin
                if(hour[1]==0)begin
                    if(hour[0]==0)begin
                        hour[0] <=0;
                        hour[1] <=0;
                    end
                    else hour[0] <= hour[0] -1;
                end
                else begin
                    hour[1] <= hour[1] -1;
                    hour[0] <= 9;
                end
            end
        end
    end
    else if(state==2'b11)begin
            if(s_start==1)begin
                hour[0] <= game_number[4];
                hour[1] <= game_number[5];
            end
            else begin
                if(sec[0]==0&sec[1]==0&min[1]==0&min[0]==0&hour[1]==0&hour[0]==0)begin
                    hour[0] <=game_time[4];
                    hour[1]<=game_time[5];
                end
                else if(game_flag==1)begin
                    if(m_down==1) hour[0]<=0;
                    else if(s_down==1) hour[1] <=0;
                    else begin
                        hour[0] <= hour[0];
                        hour[1] <= hour[1];
                    end
                end
            end
        end
    
    end
end
// day night flag 설정
always@(posedge clk) begin
    if(rst) flag= 0;
    else begin
        if(state==2'b00)begin
            if(cnt==99999& min[1]==5& min[0]==9 & sec[1]==5 & sec[0]==9 &
            hour[0]==1 & hour[1]==1) begin
                 flag = ~flag; // 0 : day 1 :night
            end
            else begin
                if(min[1]==5 & min[0]==9 &hour[1]==1&hour[0]==1&m_up==1)begin
                    flag =~flag;
                end
                else if(hour[1]==1 & hour[0] ==1 & h_up==1)begin
                    flag= ~flag;
                end
            end
        end
        if(state==2'b01)begin
            flag<=0;
        end
    end
end
//밤낮 표현
always@(posedge clk) begin 
    if(rst) day  = 8'b1111_1100;
    else begin
        if(flag==0) day = 8'b1111_1100;
        else day = 8'b1110_1100;
    end
end
always@(posedge clk)begin
    if(rst) seg_data2 = 8'b1111_1100; // 7segmenet 에 연결
    else begin
        seg_data2 = day;
    end
end
//스탑와치 flag 세우기
always@(posedge clk)begin
    if(rst) s_flag <=0;
    else if(s_start)begin
        s_flag <=1;
    end
    else if(s_stop) begin
        s_flag <=0;
    end
    else begin
        s_flag <= s_flag;
    end
end
//alarm start 알리기
always@(posedge clk)begin
    if(rst) alarm<=0;
    else begin
        if(state==2'b10)begin
            if(s_start ==1)begin //알람시작 : *버튼
                alarm <=1;
            end
            else if(alarm ==1 && alarm_end==1)begin
                alarm=0;
            end
        end
    end
end
// alarm 끝난거 알리기
always@(posedge clk)begin
    if(rst) alarm_end<=0;
    else begin

         if(state==2'b10)begin
            if(rst) alarm_end<=0;            
            else if(alarm==1&sec[0]==0&sec[1]==0&min[0]==0&min[1]==0&hour[1]==0&hour[0]==0)begin
                alarm_end<=1;
            end
            else if(alarm_end==1 & melody==38)begin
                alarm_end <=0;
            end
            else alarm_end<=alarm_end;
         end
         
    end
end
//alarm_end 이용해서 피에조 
always@(posedge clk)begin
    if(rst) begin 
        piezo_cnt <=0;
        piezo_time <=0;
        melody <=0;
    end
    else begin
        if(state==2'b10)begin
            if(alarm_end ==1)begin
                //음나오는 시간 조정 0.5초
                if(piezo_time<50000)begin
                    piezo_time <= piezo_time+1;
                    if(piezo_cnt >= piezo_half)begin
                        piezo <= !piezo;
                        piezo_cnt <= 0;
                    end
                    else piezo_cnt = piezo_cnt+1;
                end
                else begin
                    if(melody==38)begin
                        piezo_time <=0;
                        melody <= 0;
                    end
                    else begin
                        piezo_time <=0;
                        melody<= melody+1;
                    end
                    
                end
            end
        end
        else if(state==2'b11)begin
            if(game_flag ==1)begin
                    if(piezo_time<20000)begin
                        piezo_time <= piezo_time+1;
                        if(piezo_cnt >= piezo_half)begin
                            piezo <= !piezo;
                            piezo_cnt <= 0;
                        end
                        else piezo_cnt = piezo_cnt+1;
                    end
                    else begin
                        if(melody==38)begin
                            piezo_time <=0;
                        end
                        else begin
                            piezo_time <=0;
                        end
                    end
                
            end
        end
    end
end
//멜로디 설정  (piezo_half설정)
always@(posedge clk)begin
    if(rst) piezo_half = 0;
    else begin
        //노래 너무빨리 재생 금지
        if(state==2'b10 & alarm_end==1)begin
            case(melody) 
                6'd1 : piezo_half = 12'd170;
                6'd2 : piezo_half = 12'd127;
                6'd3 : piezo_half = 12'd101;
                6'd4 : piezo_half = 12'd85;
                6'd5 : piezo_half = 12'd85;
                6'd6 : piezo_half = 12'd95;
                6'd7 : piezo_half = 12'd101;
                6'd8 : piezo_half = 12'd113;
                6'd9 : piezo_half = 12'd101;
                6'd10 : piezo_half = 12'd127;
                6'd11 : piezo_half = 12'd101;
                6'd12 : piezo_half = 12'd85;
                6'd13 : piezo_half = 12'd63;
                6'd14 : piezo_half = 12'd63;
                6'd15 : piezo_half = 12'd63;
                6'd16 : piezo_half = 12'd56;
                6'd17 : piezo_half = 12'd72;
                6'd18 : piezo_half = 12'd75;
                6'd19 : piezo_half = 12'd71;
                6'd20 : piezo_half = 12'd113;
                6'd21 : piezo_half = 12'd90;
                6'd22 : piezo_half = 12'd71;
                6'd23 : piezo_half =  12'd56;
                6'd24 : piezo_half = 12'd63;
                6'd25 : piezo_half = 12'd71;
                6'd26 : piezo_half = 12'd75;
                6'd27 : piezo_half = 12'd71;
                6'd28 : piezo_half = 12'd63;
                6'd29 : piezo_half = 12'd71;
                6'd30 : piezo_half = 12'd75;
                6'd31 : piezo_half = 12'd85;
                6'd32 : piezo_half = 12'd95;              
                6'd33 : piezo_half = 12'd101;
                6'd34 : piezo_half = 12'd95;
                6'd35 : piezo_half = 12'd85;
                6'd36 : piezo_half = 12'd95;
                6'd37 : piezo_half = 12'd127;
                6'd38 : piezo_half = 12'd113;               
            endcase
        end
        else if(state==2'b11 && game_flag==1)begin
            if(h_up==1 & sec[0]==1)begin
                piezo_half = 12'd113; 
            end
            else if(m_up==1 & sec[1]==1) begin
                piezo_half = 12'd113; 
            end
            else if(s_up==1 & min[0]==1) begin
                piezo_half = 12'd113; 
            end
            else if(h_down==1 & min[1]==1) begin
                piezo_half = 12'd113; 
            end
            else if(m_down==1 & hour[0]==1) begin
                piezo_half = 12'd113; 
            end
            else if(s_down==1 & hour[1]==1) begin
                piezo_half = 12'd113; 
            end
            else piezo_half = 12'd63;
        end
        
    end
end

// 멜로디 숫자 결정 

//  초침에 동기화 시키기 
//1초당 클럭 1000번 와야함 
//모터 돌리기 // 1초에 신호 3번 가야함 //한번에 1.8도 움직임   
always@(posedge clk)begin
    if(rst) motor_state <=0;
    else begin
        if(state==2'b00)begin
            if(rst) motor_state <=0;
            else begin
                if(cnt==99999)begin
                    motor_state <= motor_state +1;
                end
                else motor_state <= motor_state;
            end
        end
        else begin
            //알람시 모터돌리기
            if(state==2'b10 & alarm==1)begin
                if(rst) motor_state <=0;
                else begin
                     if(cnt==99999)begin
                         motor_state <= motor_state +1;
                    end
                    else motor_state <= motor_state;
                end
            end
            if(state==2'b10 & alarm_end==1)begin
                if(rst) motor_state <=0;
                else begin
                     if(cnt==99999)begin
                         motor_state <= motor_state +1;
                    end
                    else motor_state <= motor_state;
                end
            end
            else if(state==2'b01 & s_flag==1)begin
                if(rst) motor_state <=0;
                else begin
                     if(cnt==99999)begin
                        motor_state <= motor_state +1;
                     end
                     else motor_state <= motor_state;
                end
            end
        end
     end
end
//motor 각도조정
always@(posedge clk)begin
    case(motor_state)
         2'd0 : smotor = 4'b0011;
         2'd1 : smotor = 4'b0110;
         2'd2 : smotor = 4'b1100;
         2'd3 : smotor = 4'b1001;
    endcase
end

// 시간 조정
always @(posedge clk)
 begin
 if(rst) motor_cnt <=0;
 else begin
    if(state==2'b00)begin
        if(motor_cnt >=1999) motor_cnt <=0;
        else motor_cnt = motor_cnt+1;
    end
 end
 end 
 // 모터제어 1
 always@(posedge clk)begin
    if(rst) a<=0;
    else begin
        if(state==2'b00)begin
            if(a>99999 * 60*60)begin
                a<=0;
            end
            else a <= a +1;
        end
    end
 end
 //모터 제어 2
 always @(posedge clk)
 if (rst) tmp = 150; // 00시 기준
 else begin
    if(a>99999 * 60 *60)begin
        tmp <= tmp+1;
    end
    
    else begin
            if(flag ==0)begin //
                case(hour[0]) 
                    4'd5: tmp = 75; //저녁 5시 
                    4'd4: tmp = 90;
                    4'd3: tmp = 105;
                    4'd2: tmp = 120;
                    4'd1: tmp = 135;
                    4'd0: if(hour[1]==1)begin
                        tmp =120;
                    end
                    else tmp = 150;
                    
                    4'd6 : tmp = 60; //저녁 6시
                    
                    4'd7 : tmp = 75;
                    4'd8 : tmp = 90;
                    4'd9 : tmp = 105;
                endcase
            end
            else begin
                case(hour[0]) 
                    4'd9 : tmp = 195;
                    4'd8 : tmp = 210;
                    4'd7 : tmp = 225;
                    
                    4'd6: tmp = 240; //새벽 6시 
                    4'd5: tmp = 225;
                    4'd4: tmp = 210;
                    4'd3: tmp = 195;
                    4'd2: tmp = 180;
                    4'd1: tmp = 165;
                        
                    4'd0: if(hour[1]==1)begin
                        tmp = 180;
                        end
                        else tmp = 150;
                        
                endcase
            end                   
        end
end
 
 always @(motor_cnt, tmp) begin
     if (motor_cnt < tmp) servo = 1;
     else servo = 0;
 end
 
 //리듬게임 
//리듬 설정 
always@(posedge clk) begin
    if(rst) rhy=0;
    if(state==2'b11)begin
        if(s_start)begin
            rhy <= (random_case/10);
        end
    end
end
//난수 생성
always@(posedge clk)begin
    if(rst) random_case <=0;
    if(state==2'b11)begin
        if(random_case==99)begin
            random_case <= 0;
        end
        random_case <=random_case +1;
    end
end
//리듬생성
always@(posedge clk)begin
    if(rst) game_number<=0;
    if(state==2'b11)begin
        if(s_start==1)begin
            case(rhy)
                4'd0: game_number=6'b111101;
                4'd1:game_number= 6'b101111;
                4'd2:game_number= 6'b111111;
                4'd3:game_number= 6'b101001;
                4'd4:game_number =6'b110111;
                4'd5:game_number= 6'b101101;
                4'd6:game_number= 6'b111001;
                4'd7:game_number= 6'b101111;
                4'd8:game_number= 6'b101011;
                4'd9:game_number= 6'b111100;
            endcase
        end
    end
end
//game_flag
always@(posedge clk)begin
    if(rst) game_flag = 0;
    else begin
        if(state==2'b11)begin
            if(s_start==1)begin
                game_flag=1;
            end
            else begin
                if(sec[0]==0&sec[1]==0&min[1]==0&min[0]==0& hour[1]==0 & hour[0]==0)begin
                    game_flag =0;
                 end
                 else if(game_time[5] ==9 &game_time[4]==9 & game_time[3]==9) begin
                   game_flag = 0;
                end
            end
        end
    end
end
//game time 정하기
always@(posedge clk)begin
    if(rst) begin
        game_time[0]<=0;
        game_time[1]<=0;
        game_time[2]<=0;
        game_time[3]<=0;
        game_time[4]<=0;
        game_time[5]<=0;
    end
    else begin
        if(state==2'b11)begin
            if(game_flag==1&&cnt==99999)begin
                if(game_time[5] ==9 &game_time[4]==9 & game_time[3]==9)begin
                            game_time[0]<=0;
                            game_time[1]<=0;
                            game_time[2]<=0;
                            game_time[3]<=0;
                            game_time[4]<=0;
                            game_time[5]<=0;
                end
                game_time[5] = game_time[5] +1;

            end
            else begin
                if(game_flag ==0 & s_start)begin
                    game_time[0] <= 0;
                    game_time[1] <= 0;
                    game_time[2] <= 0;
                    game_time[3] <= 0;
                    game_time[4] <= 0;
                    game_time[5] <= 0;
                end
                else if(game_flag==1)begin
                    game_time[0] <= cnt%10;//1의자리 `
                    game_time[1] <= (cnt%100)/10;//10의 자리`
                    game_time[2]<= (cnt%1000)/100; //100의 자리 
                    game_time[3] <= (cnt%10000)/1000; //1000의 자리 
                    game_time[4] <=  (cnt%100000)/10000;
                end
            end
        end
    end
end
endmodule
