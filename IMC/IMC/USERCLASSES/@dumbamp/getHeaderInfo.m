function headerInfo = getHeaderInfo(this)

headerInfo = getHeaderInfo(this.AMPLIFIER);%TO122205A

headerInfo.input_gain = get(this, 'input_gain');
headerInfo.input_offset = get(this, 'input_offset');
headerInfo.output_gain = get(this, 'output_gain');
headerInfo.output_offset = get(this, 'output_offset');

return;