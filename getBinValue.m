function [ bin_value ] = getBinValue( decimal_value )
%GETBINVALUE Returns the bin value of uniform patterns decimal value.
%   There are 58 uniform patterns as stated by Timo Ojala.

switch decimal_value
    case 0
        bin_value = 1;
    case 1
        bin_value = 2;
    case 2
        bin_value = 3;
    case 3
        bin_value = 4;
    case 4
        bin_value = 5;
    case 6
        bin_value = 6;
    case 7
        bin_value = 7;
    case 8
        bin_value = 8;
    case 12
        bin_value = 9;
    case 14
        bin_value = 10;
    case 15
        bin_value = 11;
    case 16
        bin_value = 12;
    case 24
        bin_value = 13;
    case 28
        bin_value = 14;
    case 30
        bin_value = 15;
    case 31
        bin_value = 16;
    case 32
        bin_value = 17;
    case 48
        bin_value = 18;
    case 56
        bin_value = 19;
    case 60
        bin_value = 20;
    case 62
        bin_value = 21;
    case 63
        bin_value = 22;
    case 64
        bin_value = 23;
    case 96
        bin_value = 24;
    case 112
        bin_value = 25;
    case 120
        bin_value = 26;
    case 124
        bin_value = 27;
    case 126
        bin_value = 28;
    case 127
        bin_value = 29;
    case 128
        bin_value = 30;
    case 129
        bin_value = 31;
    case 131
        bin_value = 32;
    case 135
        bin_value = 33;
    case 143
        bin_value = 34;
    case 159
        bin_value = 35;
    case 191
        bin_value = 36;
    case 192
        bin_value = 37;
    case 193
        bin_value = 38;
    case 195
        bin_value = 39;
    case 199
        bin_value = 40;
    case 207
        bin_value = 41;
    case 223
        bin_value = 42;
    case 224
        bin_value = 43;
    case 225
        bin_value = 44;
    case 227
        bin_value = 45;
    case 231
        bin_value = 46;
    case 239
        bin_value = 47;
    case 240
        bin_value = 48;
    case 241
        bin_value = 49;
    case 243
        bin_value = 50;
    case 247
        bin_value = 51;
    case 248
        bin_value = 52;
    case 249
        bin_value = 53;
    case 251
        bin_value = 54;
    case 252
        bin_value = 55;
    case 253
        bin_value = 56;
    case 254
        bin_value = 57;
    case 255
        bin_value = 58;
    otherwise
        bin_value = 59;
end

end

