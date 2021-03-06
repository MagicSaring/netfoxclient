--[[
	银行记录界面
	2017_08_25 MXM
]]

local BankRecordLayer = class("BankRecordLayer", function(scene)
		local bankRecordLayer = display.newLayer(cc.c4b(0, 0, 0, 125))
    return bankRecordLayer
end)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

-- 进入场景而且过渡动画结束时候触发。
function BankRecordLayer:onEnterTransitionFinish()
	self._scene:showPopWait()
	local this = self
	appdf.onHttpJsionTable(BaseConfig.WEB_HTTP_URL .. "/WS/MobileInterface.ashx","GET","action=getbankrecord&userid="..GlobalUserItem.dwUserID.."&signature="..GlobalUserItem:getSignature(os.time()).."&time="..os.time().."&number=20&page=1",function(jstable,jsdata)
			this._scene:dismissPopWait()
			if jstable then
				local code = jstable["code"]
				if tonumber(code) == 0 then
					local datax = jstable["data"]
					if datax then
						local valid = datax["valid"]
						if valid == true then
							local listcount = datax["total"]
							local list = datax["list"]
							if type(list) == "table" then
								for i=1,#list do
									local item = {}
						            item.tradeType = list[i]["TradeTypeDescription"]
						            item.swapScore = tonumber(list[i]["SwapScore"])
						            item.revenue = tonumber(list[i]["Revenue"])
						            item.date = GlobalUserItem:getDateNumber(list[i]["CollectDate"])
						            item.id = list[i]["TransferAccounts"]
						            table.insert(self._bankRecordList,item)
								end
							end
						end
					end
				end

				this:onUpdateShow()
			else
				showToast(this,"抱歉，获取银行记录信息失败！",2,cc.c3b(250,0,0))
			end
		end)
    return self
end

-- 退出场景而且开始过渡动画时候触发。
function BankRecordLayer:onExitTransitionStart()
    return self
end

function BankRecordLayer:ctor(scene)
	
	local this = self

	self._scene = scene
	
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			self:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			self:onExitTransitionStart()
		end
	end)

	self._bankRecordList = {}

    --MXM银行操作记录
    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("BankRecord/BankRecordLayer.csb",self)

    --[[
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("sp_top_bg.png")
	if nil ~= frame then
		local sp = cc.Sprite:createWithSpriteFrame(frame)
		sp:setPosition(yl.WIDTH/2,yl.HEIGHT - 51)
		self:addChild(sp)
	end
	display.newSprite("BankRecord/title_bankrecord.png")
		:move(yl.WIDTH/2,yl.HEIGHT - 51)
		:addTo(self)
	frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("sp_public_frame_0.png")
	if nil ~= frame then
		local sp = cc.Sprite:createWithSpriteFrame(frame)
		sp:setPosition(yl.WIDTH/2,326)
		self:addChild(sp)
	end
	display.newSprite("BankRecord/frame_back_2.png")
		:move(yl.WIDTH/2,326)
		:addTo(self)--]]

	--返回
	self._return = csbNode:getChildByName("Button_return")
		:addTouchEventListener(function(ref, type)
       		 	if type == ccui.TouchEventType.ended then
					this._scene:onKeyBack()
				end
			end)
    --[[
	--标题列
	display.newSprite("BankRecord/table_bankrecord_line.png")
		:move(yl.WIDTH/2,520)
		:addTo(self)
	display.newSprite("BankRecord/title_bankrecord_0.png")
		:move(230,550)
		:addTo(self)
	display.newSprite("BankRecord/title_bankrecord_1.png")
		:move(500,550)
		:addTo(self)
	display.newSprite("BankRecord/title_bankrecord_2.png")
		:move(700,550)
		:addTo(self)
	display.newSprite("BankRecord/title_bankrecord_3.png")
		:move(900,550)
		:addTo(self)
	display.newSprite("BankRecord/title_bankrecord_4.png")
		:move(1110,550)
		:addTo(self) 

	--无记录提示
	self._nullTipLabel = cc.Label:createWithTTF("没有银行记录","base/fonts/round_body.ttf",32)
			:move(yl.WIDTH/2,326)
			:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
			:setTextColor(cc.c4b(216,187,115,255))
			:setAnchorPoint(cc.p(0.5,0.5))
			:addTo(self)--]]

    --暂未记录提示
    self._nullTipSprite = csbNode:getChildByName("tip_no_record")
        :setVisible(false)

	--记录列表
	self._listView = cc.TableView:create(cc.size(1204, 454))
	self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
	self._listView:setPosition(cc.p(67,60))
	self._listView:setDelegate()
	self._listView:addTo(self)
	self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self._listView:registerScriptHandler(self.cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	self._listView:registerScriptHandler(self.tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	self._listView:registerScriptHandler(self.numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    --[[
	display.newSprite("BankRecord/frame_back_1.png")
		:move(yl.WIDTH/2,326)
		:addTo(self)--]]

end

function BankRecordLayer:onUpdateShow()
	print("BankRecordLayer:onUpdateShow")

	if not self._bankRecordList then
		print("self._nullTipLabel:setVisible(true)")
		--self._nullTipLabel:setVisible(true)
        self._nullTipSprite:setVisible(true)
	else
		--self._nullTipLabel:setVisible(false)
        self._nullTipSprite:setVisible(false)
	end

	self._listView:reloadData()

end

---------------------------------------------------------------------

--子视图大小
function BankRecordLayer.cellSizeForTable(view, idx)
  	return 1204 , 76
end

--子视图数目
function BankRecordLayer.numberOfCellsInTableView(view)
	return #view:getParent()._bankRecordList
end
	
--获取子视图
function BankRecordLayer.tableCellAtIndex(view, idx)		
	local cell = view:dequeueCell()
	
	local item = view:getParent()._bankRecordList[idx+1]

	local width = 1204
	local height= 76

	if not cell then
		cell = cc.TableViewCell:new()
	else
		cell:removeAllChildren()
	end

	display.newSprite("BankRecord/table_bankrecord_cell_"..(idx%2)..".png")
		:move(width/2,height/2)
		:addTo(cell)

	--日期
	local date = os.date("%Y/%m/%d %H:%M:%S", tonumber(item.date)/1000)
	-- print(date)
	-- print(""..tonumber(item.date))
	cc.Label:createWithTTF(date,"base/fonts/round_body.ttf",32)
		:move(170,height/2)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(216,187,115,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:addTo(cell)

    --交易类别
	cc.Label:createWithTTF(item.tradeType,"base/fonts/round_body.ttf",32)
		:move(455,height/2)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(216,187,115,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:addTo(cell)
    
    --交易金额
	cc.Label:createWithTTF(string.formatNumberFhousands(item.swapScore),"base/fonts/round_body.ttf",32)
		:move(740,height/2)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(216,187,115,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:addTo(cell)
    
    --转账ID
	cc.Label:createWithTTF(item.id,"base/fonts/round_body.ttf",32)
		:move(812,height/2)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(216,187,115,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:addTo(cell)
        :setVisible(false)
    
    --服务费
	cc.Label:createWithTTF(string.formatNumberFhousands(item.revenue),"base/fonts/round_body.ttf",32)
		:move(1058,height/2)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(216,187,115,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:addTo(cell)

	return cell
end
---------------------------------------------------------------------
return BankRecordLayer