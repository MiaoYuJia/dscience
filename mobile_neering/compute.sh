train_neg=`cat dtrain | awk '$1=="0" '| wc -l`
train_pos=`cat dtrain | awk '$1=="1" '| wc -l`
x=`expr $train_neg / $train_pos`
echo train neg:pos is  $x, pos  is: $train_pos , neg is : $train_neg

test_neg=`cat dtest | awk '$1=="0" '| wc -l`
test_pos=`cat dtest | awk '$1=="1" '| wc -l`
y=`expr $test_neg / $test_pos`
echo test neg:pos is  $y, pos is:$test_pos , neg is : $test_neg

train=`cat dtrain | wc -l`
tet=`cat dtest | wc -l`
z=`expr $train / $tet`
echo tran:test is $z
