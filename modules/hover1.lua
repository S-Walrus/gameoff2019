local Hover = {}

Hover._ = {}

function Hover:addArea(area)
    rect = {
        math.min(area[1], area[3]),
        math.min(area[2], area[4]),
        math.max(area[1], area[3]),
        math.max(area[2], area[4])
    }
    Area = {
        area=rect,
        hover=false,
        down=false
    }
    function Area:onMouseOver(f)
        self.mouseOver = f
        return self
    end
    function Area:onMouseEnter(f)
        self.mouseEnter = f
        return self
    end
    function Area:onMouseLeave(f)
        self.mouseLeave = f
        return self
    end
    function Area:onMousePressed(f)
        self.mousePressed = f
        return self
    end
    function Area:onMouseReleased(f)
        self.mouseReleased = f
        return self
    end
    function Area:onClick(f)
        self.click = f
        return self
    end
    table.insert(self._, Area)
    return Area
end

function Hover:update(mouseX, mouseY)
    mouseX = mouseX or love.mouse.getX()
    mouseY = mouseY or love.mouse.getY()
    for i, box in ipairs(self._) do
        if mouseX >= box.area[1] and mouseX <= box.area[3]
           and mouseY >= box.area[2] and mouseY <= box.area[4] then
            if box.mouseOver then box.mouseOver() end
            if not box.hover then
                box.hover = true
                if box.mouseEnter then box.mouseEnter() end
            end
            if not box.down and love.mouse.isDown(1) then
                box.down = true
                if box.mousePressed then box.mousePressed() end
            end
            if box.down and not love.mouse.isDown(1) then
                box.down = false
                if box.click then box.click() end
                if box.mouseReleased then box.mouseReleased() end
            end
        else
            if box.hover then
                box.hover = false
                if box.mouseLeave then box.mouseLeave() end
            end
            if box.down then
                box.down = false
                if box.mouseReleased then box.mouseReleased() end
            end
        end
    end
end

return Hover