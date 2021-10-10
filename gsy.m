Train= readtable('titanic\train.csv');
Test = readtable('titanic\test.csv');
head(Train)
head(Test)
%载入数据集
%年龄段分类
Agelevel = 10;
Agenum = max(ceil(Test.Age/Agelevel));
Train.Age = ceil(Train.Age/Agelevel)*Agelevel;
Test.Age = ceil(Test.Age/Agelevel)*Agelevel;
%做存活率关于性别、年龄的统计
Surv_Sex = grpstats(Train(:,{'Survived','Sex'}),{'Survived','Sex'});
Surv_Age = grpstats(Train(:,{'Survived','Age'}),{'Survived','Age'});
%计算先验概率与条件概率
for i = [1,2]
  
    P_Survive(i) = (sum(Train.Survived == i-1)+1)/(length(Train.Survived)+2);
    for j = 1 : Agenum
        if ismember(j * Agelevel,Surv_Age.Age(Surv_Age.Survived == i-1))
            P_Age(i,j) = (Surv_Age.GroupCount(Surv_Age.Survived == i-1 & Surv_Age.Age == j * Agelevel)+1)/(sum(Surv_Age.GroupCount(Surv_Age.Survived == i-1))+Agenum);
        else
            P_Age(i,j)=1/(sum(Surv_Age.GroupCount(Surv_Age.Survived == i-1))+Agenum);
        end
    end
    P_Sex(i,:) = (Surv_Sex.GroupCount(Surv_Sex.Survived == i-1)+1)/(sum(Surv_Sex.GroupCount(Surv_Sex.Survived == i-1))+2);
end
%计算后验概率
isfemale = ismember(Test.Sex(:),'female');
P_Alive_Sex = P_Sex(2,2)*isfemale+P_Sex(2,1)*(1-isfemale);
P_Dead_Sex = P_Sex(1,2)*isfemale+P_Sex(1,1)*(1-isfemale);
P_Alive_Age = 0;
P_Dead_Age = 0;
for i = 1 : Agenum
    P_Alive_Age = P_Alive_Age+P_Age(2,i)*(Test.Age == i * Agelevel);
    P_Dead_Age = P_Dead_Age+P_Age(1,i)*(Test.Age == i * Agelevel);
end
P_Alive(1,:)=P_Survive(2).*P_Alive_Sex.*P_Alive_Age;
P_Dead(1,:)=P_Survive(1).*P_Dead_Sex.*P_Dead_Age;
Survive=P_Alive-P_Dead;
Final(:,1)=892:1:1309;
Final(:,2)=Survive(1,:)>0;
title = {'PassengerId','Survived'};
result_table = table(Final(:,1),Final(:,2),'VariableNames',title);
writetable(result_table,'submission.csv');