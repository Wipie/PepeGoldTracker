local LibEasyMenu = LibStub:NewLibrary("LibEasyMenu", 1);

if not LibEasyMenu then
    return;
end


function EasyMenu_Initialize(frame, level, menuList)
    for index = 1, #menuList do
        local value = menuList[index]
        if (value.text) then
            value.index = index;
            UIDropDownMenu_AddButton( value, level );
        end
    end
end

function LibEasyMenu:EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay)
    if ( displayMode == "MENU" ) then
        menuFrame.displayMode = displayMode;
    end
    UIDropDownMenu_Initialize(menuFrame, EasyMenu_Initialize, displayMode, nil, menuList);
    ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay);
end