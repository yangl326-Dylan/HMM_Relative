1. 调研下单数据流上的异常检测\预测
2. 实验部分比较时间效率、准确性、以及及时性
3. 和Find Semantic这篇文章的区别
4. 算法的改编，可以参照下Find Semantic这篇文章
5. 话题有点老，创新需要好好想想
   online model 的好处（普遍性）：
   5.0 this is the first literal work using HMM on Streaming Data (有待调研)
   5.1 online adapted hmm model can used in the situation of streaming environment, instead of the finite time series. it's much more practical, since broad applications generate streaming data, for example the various sensor data.
   5.2 online adapted hmm model can reveal the leatest internal dynamics of the system, instead of a fixed model. it's much more precious, since the trend of data can vary with time, for example the seasonal variations of water consumption.
   //5.2 可以做下试验测试下
   5.3 Updating strategy of online hmm avoid to recompute the hmm model from scratch at every timestamp, and can reduce the complexity as much as possible. [这个可以做个对比试验：online model vs hmm]
   5.4 We take a further step of using HMM on Streaming data compared with the algoriths in "Finding Semantics in Time Series". what's more, we consider the average value of 
       a group of neighboring values into a pattern, instead of the shape (e.i. slope and length) in that paper. It is more reasonable. Firstly, considering an anormaly phenomenon
       that the shape of a piecewise of data remain the same but the values are different, if we using the slope to represent the data, it will can't tell the normal from the abnormal. Secondly, 
       although the same values may be both in an upward trend and in an downward trend, the relationship among neighboring patterns have the power to identify which trend it is in, and our experiments
       shows that our pattern has more predictive power then the pattern of shape in that paper.   

目前重点在3和4

2014/7/1 先分析下数据流的特征
2014/7/3 预测
case 1 对于正常状态的数据流，该模型预测的准确度是怎么样的？ 新的离散化方式具有更好的预测能力，预测的准确度更高！！
     采用小概率原理：小概率事件在一次观测中不应该出现
    
case 2 对于有异常的数据流，该模型是否可以及时检测到异常？

2014/7/5 观测值相同，是因为他们对应的系统状态是相同的，相邻时刻的系统状态相似，所以他们生成的观测相似
