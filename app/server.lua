Server = {}

local function TryCreateDataDirectory(self)
    local info = love.filesystem.getInfo(love.filesystem.getSaveDirectory() .. "/" .. self.DATA_DIR)
    assert(not info or info.type == "directory")
    if not info then
        return love.filesystem.createDirectory(self.DATA_DIR)
    end
    return true
end

function Server:Init(params)
    App.Init(self, params)
    self.isServer = true
    self.DATA_DIR = "save"
    self.DATA_FILE = "game-01.lua"
    assert(TryCreateDataDirectory(self))

    if self.root then
        self.screenManager = ScreenManager()
        self.screenManager:Push(ScreenSaver())
    end
    self.connectionManager = ConnectionManager(params.address, params.port)
end

function Server:Load()
    self:LoadData(self.DATA_FILE)
    self.connectionManager:Start(function(connection)
        connection:Start(function(msg)
            self.data = msg
            self:SaveData(self.DATA_FILE)
            for c in pairs(self.connectionManager:GetConnections()) do
                if c ~= connection then
                    c:SendRequest(self.data, function()
                        app.logger:Log("Received game data from other clients")
                        return {}
                    end)
                end
            end
            return {}
        end)
        connection:SendRequest(self.data, function()
            app.logger:Log("Received game data fist time")
            return {}
        end)
    end, function()
    end)
end

function Server:LoadData(file)
    local content = love.filesystem.read(self.DATA_DIR .. "/" .. file)
    self.data = table.fromstring(content)
end

function Server:SaveData(file)
    local content = table.tostring(self.data)
    local success, message = love.filesystem.write(self.DATA_DIR .. "/" .. file, content)
    assert(success, message)
end

MakeClassOf(Server, App)
