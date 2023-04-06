local pretty = require "cc.pretty"


local logger = {
    terminal = nil,
    lastLineWriten = nil
}

function logger.init(terminal)
    logger.terminal = terminal
end

function logger.log(text)
    if logger.terminal ~= nil then
        local originalTerminal = term.current()
        if (logger.terminal == nil or originalTerminal == logger.terminal) then
            pretty.pretty_print(text)
            return
        end
        term.redirect(logger.terminal)
        pretty.pretty_print(text)
        term.redirect(originalTerminal)

    end
end

return logger