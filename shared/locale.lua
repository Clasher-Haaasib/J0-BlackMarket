L = nil
if Config and Config.Locale then
    local code = Config.Locale
    if code == "fr" and L_fr then L = L_fr
    elseif code == "es" and L_es then L = L_es
    elseif code == "bn" and L_bn then L = L_bn
    else L = L_en end
end
L = L or L_en or {}
