--  © ООО «1С-Софт», 2023.  Все права защищены
--  Copyright © 2023, 1C-Soft LLC. All rights  reserved

_G.techlog_events = {
    ADDIN = {"Location", "Func", "Crashed"},
    ATTN = {"Descr"},
    CALL = {"IName", "MName", "RetExcp"},
    CLSTR = {"Event", "Txt"},
    CONFLOADFROMFILES = {"Action"},
    CONN = {"t:clientID", "t:connectID", "Txt"},
    DB2 = {"Func", "Sql"},
    DBCOPIES = {"Func"},
    DBMSSQL = {"Func", "Sql"},
    DBORACLE = {"Func", "Sql"},
    DBPOSTGRS = {"Func", "Sql"},
    DBV8DBENG = {"Sql"},
    EDS = {"Sql", "Exception"},
    EVENTLOG = {"Func", "FileName"},
    EXCP = {"Descr"},
    EXCPCNTX = {"SrcName"},
    FTEXTCheck = {"Func"},
    FTEXTUpd = {"Func"},
    FTS = {"Func"},
    HASP = {"Txt"},
    LEAKS = {"Descr"},
    LIC = {"Txt"},
    MAILPARSEERR = {"Method", "MessageUID"},
    PROC = {"process", "Txt"},
    QERR = {"Descr", "Query"},
    SCALL = {"IName", "MName", "Method"},
    SCOM = {"Func"},
    SDBL = {"Func", "Sdbl"},
    SDGC = {"FilesSize", "UsedSize"},
    SESN = {"Descr", "SeanceID"},
    SRVC = {"Descr"},
    STORE = {"StorageGUID", "UseMode", "ReadOnlyMode", "MinimalWriteSize", "BackupType", "BackupFileName", "BackupBaseFileName", "Event"},
    STT = {"Func"},
    STTAdm = {"Func"},
    SYSTEM = {"func", "file", "line"},
    TDEADLOCK = {"DeadlockConnectionIntersections"},
    TLOCK = {"Regions", "Locks", "WaitConnections"},
    TTIMEOUT = {"WaitConnections"},
    VRSCACHE = {"Sql"},
    VRSREQUEST = {"Method", "URI", "Headers", "Body", "Status", "Phrase", "Cached"},
    VRSRESPONSE = {"Method", "URI", "Headers", "Body", "Status", "Phrase", "Cached"},
    VIDEOCALL = {"InMessage", "OutMessage"},
    VIDEOCONN = {"PeerId", "StreamType", "Status", "Connection"},
    VIDEOSTATS = {"PeerId", "Type", "Direction", "Value"}
}

_G.debug_events = {
    DBMSSQL = true,
    DBV8DBENG = true,
    DB2 = true,
    DBCOPIES = true,
    DBORACLE = true,
    DBPOSTGRS = true,
    SDBL = true,
    SCRIPTCIRCREFS = true,
    MEM = true,
    LEAK = true
}

_G.warning_events = {
    ATTN = true
}

_G.log_level_priority = {
    DEBUG = 1,
    INFO = 2,
    WARNING = 3,
    ERROR = 4,
    NONE = 5
}

_G.running_info = {
    last_check = nil,
    settings = {}
}

function timestamp_to_unixtime(ts)

    local p = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+).(%d+)"
    local y, mon, d, h, m, s, mcs = string.match(ts, p)
    local dateTime = {
        year = y,
        month = mon,
        day = d,
        hour = h,
        min = m,
        sec = s
    }
    local result = nil

    if not mcs then
        result = os.time(dateTime)
    else
        result = os.time(dateTime) + (math.floor(mcs / 1000) / 1000)
    end

    return result

end

function set_number_value(record, prop)
    if not record[prop] then
        return
    end
    record[prop] = tonumber(record[prop]) or 0
end

function convert_number_fields(record)
    set_number_value(record, "duration")
    set_number_value(record, "MemoryPeak")
    set_number_value(record, "depth")
    set_number_value(record, "OSThread")
    set_number_value(record, "t:clientID")
    set_number_value(record, "t:connectID")
    set_number_value(record, "dbpid")
    set_number_value(record, "callWait")
    set_number_value(record, "Calls")
    set_number_value(record, "CallID")
    set_number_value(record, "ClientID")
    set_number_value(record, "CpuTime")
    set_number_value(record, "DstClientID")
    set_number_value(record, "DstPid")
    set_number_value(record, "Nmb")
    set_number_value(record, "Memory")
    set_number_value(record, "MemoryPeak")
    set_number_value(record, "OSThread")
    set_number_value(record, "OutBytes")
    set_number_value(record, "Pid")
    set_number_value(record, "Rows")
    set_number_value(record, "RowsAffected")
    set_number_value(record, "SrcPid")
    set_number_value(record, "TargetCall")
    set_number_value(record, "Trans")
    set_number_value(record, "first")
end

function check_log_level(level_event, min_level)

    if min_level == "NONE" then
        return false
    end

    local level_event_priority = _G.log_level_priority[level_event]

    if not level_event_priority then
        level_event_priority = _G.log_level_priority["INFO"]
    end

    local min_level_priority = _G.log_level_priority[min_level]

    if not min_level_priority then
        min_level_priority = _G.log_level_priority["INFO"]
    end
    return level_event_priority >= min_level_priority

end

function default_settings()

    return {
        settings = {
            level = "INFO"
        }
    }

end

function load_ini(fileName)

    local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName);
    local data = {};
    local section;

    for line in file:lines() do
        local tempSection = line:match('^%[([^%[%]]+)%]$');
        if(tempSection)then
            section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
            data[section] = data[section] or {};
        else
            local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
            if(param and value ~= nil)then
            if(tonumber(value))then
                value = tonumber(value);
            elseif(value == 'true')then
                value = true;
            elseif(value == 'false')then
                value = false;
            end
            if(tonumber(param))then
                param = tonumber(param);
            end
            data[section][param] = value;
            end
        end
    end

    file:close();

    return data;

end

function read_settings()

    if _G.running_info.last_check then
        local current_date = os.time ()
        difference = os.difftime(current_date, _G.running_info.last_check)

        if difference < 60 then
            if not _G.running_info.settings then
                _G.running_info.settings = default_settings()
            end

            return _G.running_info.settings
        end
    end

    _G.running_info.last_check = os.time ()

    local name = "/var/1C/fluent-bit/settings.ini"
    local settings_file = io.open(name, "r")

    if not settings_file then
        _G.running_info.settings = default_settings()
        return _G.running_info.settings
    else
        io.close(settings_file)
        local data = load_ini(name);
        if data then
            _G.running_info.settings = data
        else
            _G.running_info.settings = default_settings()
        end
        return data
    end

end

function transform_techlog(tag, timestamp, record)

    local name = record["name"]

    local messageProps = _G.techlog_events[name];
    if not messageProps then
        return -1, nil, nil
    end

    local config = read_settings()
    local settings = config["settings"]
    local log_level = string.gsub(settings["level"], "%s+", "");

    local event_name = record["name"]
    local level_type = 3
    local record_log_level = "INFO"

    if record["level"] then
        record_log_level = record["level"]
    else
        if event_name == "SYSTEM" then
            record_log_level = record["level"]
        elseif event_name == "EXCP" then
            if record["Descr"] and string.find(record["Descr"], "shown to the user") then 
                record_log_level = "ERROR"
            else
                record_log_level = "WARNING"
            end
        elseif event_name == "EXCPCNTX" then
            record_log_level = "ERROR"
        elseif record["name"] == "CALL" then
            if record["RetExcp"] then
                record_log_level = "ERROR"
            end
        elseif _G.warning_events[event_name] then
            record_log_level = "WARNING"
        elseif _G.debug_events[event_name] then
            record_log_level = "DEBUG"
        end
    end

    if record_log_level == "TRACE" then
        record_log_level = "DEBUG"
    end

    if not check_log_level(record_log_level, log_level) then
        return -1, nil, nil
    end

    local result = record
    result["logLevel"] = record_log_level
    result["level"] = nil

    local record_ts = record["ts"]
    local wrong_ts = tonumber(record_ts)
    if wrong_ts then
        return -1, nil, nil
    end

    local ts = timestamp_to_unixtime(record_ts)
    result["ts"] = nil

    local message = {}
    local j = 1

    for i = 1, #messageProps do
      local prop = messageProps[i]
      local value = record[prop]
      if value then
         message[j] = prop..": "..value
         result[prop] = nil
         j = j + 1
      end
    end

    result["message"] = table.concat(message,", ")
    result["Datetime"] = ts

    if event_name == "SYSTEM" then
        result["class"] = record["className"]
    end

    local serviceName = os.getenv("E1C_SERVICE_NAME")
    if serviceName then
      result["serviceName"] = serviceName
    end

    local serviceVersion = os.getenv("E1C_SERVICE_VERSION")
    if serviceVersion then
      result["serviceVersion"] = serviceVersion
    end

    local instanceID = os.getenv("E1C_INSTANCE_ID")
    if instanceID then
      result["instanceID"] = instanceID
    end

    convert_number_fields(record)

    return 1, ts, result

end