using Dates
using Printf

function getFirstDate()
    timeNow = now()
    return @sprintf("[%02d-%02d %02d:%02d:%02d:%03d]", month(timeNow), day(timeNow), hour(timeNow), minute(timeNow), second(timeNow), Dates.value(timeNow) % 1_000_000_000 ÷ 1_000_000)
end