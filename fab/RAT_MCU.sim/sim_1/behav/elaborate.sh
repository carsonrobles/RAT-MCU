#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2016.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 49acbf43991e48bb8ce5ab7ba8dd6c14 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L secureip --snapshot PCWrapperTestBench_behav xil_defaultlib.PCWrapperTestBench -log elaborate.log
