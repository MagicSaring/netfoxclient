#ifndef TABLE_FRAME_SINK_HEAD_FILE
#define TABLE_FRAME_SINK_HEAD_FILE

#pragma once

#include "Stdafx.h"
#include "GameLogic.h"
#include "HistoryScore.h"
#include "ServerControl.h"
#include "DlgCustomRule.h"

//////////////////////////////////////////////////////////////////////////
#define CHEAT_TYPE_LOST		0		//输
#define CHEAT_TYPE_WIN		1		//赢
//游戏桌子类
class CTableFrameSink : public ITableFrameSink, public ITableUserAction
{
  //游戏变量
protected:
  bool                    	m_bSpecialClient[GAME_PLAYER];          //特殊终端
  WORD					  	m_wBankerUser;							//庄家用户
  WORD					  	m_wFisrtCallUser;						//始叫用户
  WORD					  	m_wCurrentUser;							//当前用户
  SCORE				  	m_lExitScore;							//强退分数
  SCORE                	m_lDynamicScore;                        //总分
  static bool             	m_bFirstInit;							//初始化
  SCORE                	m_lBonus;

  //用户数据
protected:
  BYTE                    	m_cbDynamicJoin[GAME_PLAYER];           //动态加入
  BYTE                    	m_cbPlayStatus[GAME_PLAYER];			//游戏状态
  BYTE                    	m_cbCallStatus[GAME_PLAYER];			//叫庄状态
  int						m_nUserCallStatus[GAME_PLAYER];			//叫庄状态
  BYTE					  	m_cbOxCard[GAME_PLAYER];				//牛牛数据
  SCORE				  	m_lTableScore[GAME_PLAYER];				//下注数目
  bool					  	m_bBuckleServiceCharge[GAME_PLAYER];	//收服务费

  SCORE                	m_lUserBeginScore[GAME_PLAYER];			//开始分数(测试用)
  SCORE                	m_lUserTableScore[GAME_PLAYER];			//下注分数(测试用)

  //扑克变量
protected:
  BYTE						m_cbHandCardData[GAME_PLAYER][MAX_COUNT];//桌面扑克

  //下注信息
protected:
  SCORE					m_lTurnMaxScore[GAME_PLAYER];			//最大下注

  //服务控制
protected:
  HINSTANCE					m_hInst;								//控制句柄
  IServerControl*			m_pServerContro;						//控制组件

  //组件变量
protected:
  CGameLogic				m_GameLogic;							//游戏逻辑
  ITableFrame				* m_pITableFrame;						//框架接口
  CHistoryScore				m_HistoryScore;							//历史成绩
  tagGameServiceOption      *m_pGameServiceOption;					//配置参数
  tagGameServiceAttrib      *m_pGameServiceAttrib;					//游戏属性

  //属性变量
protected:
  static const WORD			m_wPlayerCount;							//游戏人数
  DWORD						m_dwGameTime;						    //开始时间


    SCORE						m_WinnerScore;							//该盘总输赢
  //函数定义
public:
  //构造函数
  CTableFrameSink();
  //析构函数
  virtual ~CTableFrameSink();

  //基础接口
public:
  //释放对象
  virtual VOID Release() {}
  //接口查询
  virtual void * QueryInterface(const IID & Guid, DWORD dwQueryVer);

  //管理接口
public:
  //初始化
  virtual bool Initialization(IUnknownEx * pIUnknownEx);
  //复位桌子
  virtual void RepositionSink();

  virtual bool IsUserPlaying(WORD wChairID);
  //游戏事件
public:
  //游戏开始
  virtual bool OnEventGameStart();
  //游戏结束
  virtual bool OnEventGameConclude(WORD wChairID, IServerUserItem * pIServerUserItem, BYTE cbReason);
  //发送场景
  virtual bool OnEventSendGameScene(WORD wChairID, IServerUserItem * pIServerUserItem, BYTE bGameStatus, bool bSendSecret);


  //事件接口
public:
  //定时器事件
  virtual bool OnTimerMessage(DWORD dwTimerID, WPARAM wBindParam);
  //游戏消息处理
  virtual bool OnGameMessage(WORD wSubCmdID, void * pDataBuffer, WORD wDataSize, IServerUserItem * pIServerUserItem);
  //框架消息处理
  virtual bool OnFrameMessage(WORD wSubCmdID, void * pDataBuffer, WORD wDataSize, IServerUserItem * pIServerUserItem);
  //数据事件
  virtual bool OnGameDataBase(WORD wRequestID, VOID * pData, WORD wDataSize)
  {
    return true;
  }

  //查询接口
public:
  //查询限额
  virtual SCORE QueryConsumeQuota(IServerUserItem * pIServerUserItem);
  //最少积分
  virtual SCORE QueryLessEnterScore(WORD wChairID, IServerUserItem * pIServerUserItem)
  {
    return 0;
  }
  //查询服务费
  virtual bool QueryBuckleServiceCharge(WORD wChairID);
  //数据事件
  virtual bool OnDataBaseMessage(WORD wRequestID, VOID * pData, WORD wDataSize)
  {
    return false;
  }
  //积分事件
  virtual bool OnUserScroeNotify(WORD wChairID, IServerUserItem * pIServerUserItem, BYTE cbReason)
  {
    return false;
  }
  //设置基数
  virtual void SetGameBaseScore(SCORE lBaseScore)
  {
    return;
  }


  //用户事件
public:
  //用户断线
  virtual bool OnActionUserOffLine(WORD wChairID, IServerUserItem * pIServerUserItem)
  {
    return true;
  }
  //用户重入
  virtual bool OnActionUserConnect(WORD wChairID, IServerUserItem * pIServerUserItem)
  {
    return true;
  }
  //用户坐下
  virtual bool OnActionUserSitDown(WORD wChairID, IServerUserItem * pIServerUserItem, bool bLookonUser);
  //用户起立
  virtual bool OnActionUserStandUp(WORD wChairID, IServerUserItem * pIServerUserItem, bool bLookonUser);
  //用户同意
  virtual bool OnActionUserOnReady(WORD wChairID, IServerUserItem * pIServerUserItem, VOID * pData, WORD wDataSize)
  {
    return true;
  }
  //用户下注
  virtual bool OnActionUserPour(WORD wChairID, IServerUserItem * pIServerUserItem){return true;}
  //游戏事件
protected:
  //叫庄事件
  bool OnUserCallBanker(WORD wChairID, BYTE bBanker);
  //加注事件
  bool OnUserAddScore(WORD wChairID, SCORE lScore);
  //摊牌事件
  bool OnUserOpenCard(WORD wChairID, BYTE bOx);
  //写分函数
  bool TryWriteTableScore(tagScoreInfo ScoreInfoArray[]);

  //功能函数
protected:
  //扑克分析
  void AnalyseCard();
  //最大下分
  SCORE GetUserMaxTurnScore(WORD wChairID);
  //是否可加
  bool UserCanAddScore(WORD wChairID, SCORE lAddScore);
  //判断库存
  bool JudgeStock();
  //是否衰减
  bool NeedDeductStorage();
  //更新房间用户信息
  void UpdateUserRosterInfo(IServerUserItem *pIServerUserItem, SCORE lGameScore = 0LL, USERROSTER userRoster = INVALID_ROSTER, SCORE lScoreLimit = 0LL);
  //解除用户名单
  void RemoveUserRoster();
  //计算机器人分数
  SCORE CalculateAndroidScore(bool bIsAiBanker, WORD &wWinUser);
  void ProbeJudge(WORD wChairIDCtrl,BYTE cbCheatType);
  void AndroidHuanPai();
  void BeginChange(bool IsLoss );
};

//////////////////////////////////////////////////////////////////////////

#endif
