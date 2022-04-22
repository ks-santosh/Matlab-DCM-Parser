# Matlab-DCM-Parser
The DcmParser m-script reads the DCM file and convert its data into a containers.Map object. This object retains DCM metadata, comments, and data order for reproducing DCM file from the object. Ensure the DCM file conforms to the specifications outlined in [DCM_File_Formats](https://www.etas.com/download-center-files/products_ASCET_Software_Products/TechNote_DCM_File_Formats.pdf "DCM File Formats").

## Demo
The log shows the ouput after parsing [TestDCM.dcm](/DcmParser/TestDCM.dcm)

```matlab
>> DcmVarMap = DcmParser('TestDCM.dcm');
START
-> Reading TestDCM.dcm ...
-> Successfully parsed DCM!
-> Number of variables read: 7
END 
>> DcmVarMap('Start')

ans =

  1×19 cell array

  Columns 1 through 4

    {'* DAMOS format'}    {'* Created by AS…'}    {'* Creation date…'}    {'*'}

  Columns 5 through 7

    {'* DamosDataFile…'}    {'* DamosExtensio…'}    {'* DamosFormatVe…'}

  Columns 8 through 10

    {'* DamosCaseSens…'}    {'* DamosIncludeB…'}    {'* DamosIncludeD…'}

  Columns 11 through 13

    {'* DamosBooleanF…'}    {'* DamosEnumerat…'}    {'* DamosShowInpu…'}

  Columns 14 through 17

    {'* DamosInputLog…'}    {'* DamosShowOutp…'}    {'* DamosOutputLo…'}    {0×0 char}

  Columns 18 through 19

    {'KONSERVIERUNG_F…'}    {0×0 char}

>> DcmVarMap('Order')

ans =

  1×8 cell array

  Columns 1 through 6

    {'Start'}    {'array'}    {'cont'}    {'distrib'}    {'One_D_group'}    {'sdisc'}

  Columns 7 through 8

    {'Two_D_group'}    {'udisc_1'}

>> DcmVarMap('array')

ans =

  1×7 cell array

  Columns 1 through 6

    {'FESTWERTEBLOCK'}    {[4]}    {'sample temperat…'}    {'NA'}    {'NA'}    {'Â° C'}

  Column 7

    {1×4 cell}

>> Temp = DcmVarMap('Two_D_group')

Temp =

  1×14 cell array

  Columns 1 through 6

    {'GRUPPENKENNFELD'}    {[3]}    {[3]}    {'engine calibrat…'}    {'NA'}    {'NA'}

  Columns 7 through 11

    {'A'}    {'m/s'}    {'Nm'}    {'distrib\Module_…'}    {'distrib\Module_…'}

  Columns 12 through 14

    {1×3 cell}    {1×3 cell}    {3×3 cell}

>> Temp(end)

ans =

  1×1 cell array

    {3×3 cell}

>> Temp{end}

ans =

  3×3 cell array

    {'1.0'}    {'2.0'}    {'3.0'}
    {'2.0'}    {'4.0'}    {'6.0'}
    {'3.0'}    {'6.0'}    {'9.0'}

>> Temp{end-1}

ans =

  1×3 cell array

    {'1.0'}    {'2.0'}    {'3.0'}

>> Temp{end-2}

ans =

  1×3 cell array

    {'1.0'}    {'2.0'}    {'3.0'}

>> 
```