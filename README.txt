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
   5.4 

目前重点在3和4

2014/7/1 先分析下数据流的特征