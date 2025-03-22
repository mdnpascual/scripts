--- STEAMODDED HEADER
--- MOD_NAME: Deck Seer
--- MOD_ID: DeckSeer
--- MOD_AUTHOR: [thevdude]
--- MOD_DESCRIPTION: Peer into the future of your deck (see upcoming draws)

----------------------------------------------
------------MOD CODE -------------------------
--[[
  create a card area to place the top 3 cards from the deck into
--]]
local setScreenPositionsRef = set_screen_positions
function set_screen_positions()
  G.seerea = CardArea(
    0, 0,
    3.5*G.CARD_W,
    0.95*G.CARD_H,
    {card_limit = 8, type = 'consumeable'}
  )

  setScreenPositionsRef()

  if G.STAGE == G.STAGES.RUN then
    G.seerea.T.x = G.jokers.T.x + G.jokers.T.w - 0.8 -- + 0.2
    G.seerea.T.y = 2.5

    G.seerea:hard_set_VT()
  end
end

--[[
  i'm sure there's a better way to do this, but this works so i'm leaving it
--]]
local setAlertsRef = set_alerts
function set_alerts()
  setAlertsRef()
  if G.seerea then
    if G.STATE ~= G.STATES.SELECTING_HAND and G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND then
      hide_seerea()
      return
    end
    G.HAS_MEDIUM = true
    show_seerea()
    -- G.HAS_MEDIUM = false
    -- if G.consumeables and G.consumeables.cards then
    --   for _, v in ipairs(G.consumeables.cards) do
    --     -- if v.ability.name == 'Medium' then
    --     G.HAS_MEDIUM = true
    --     show_seerea()
    --     break
    --     -- end
    --   end
    -- end
    if not G.HAS_MEDIUM then
      hide_seerea()
    end
  end
end

function hide_seerea()
  G.E_MANAGER:add_event(Event({
    trigger = 'immediate',
    blocking = false,
    blockable = true,
    func = (function()
      for _, v in ipairs(G.seerea.cards) do
        if v.states.visible then
          fakeDissolve(v,{G.C.GOLD,G.C.BLUE,G.C.PURPLE})
        end
      end
      return true
    end)
  }))
end

function show_seerea()
  G.E_MANAGER:add_event(Event({
    trigger = 'immediate',
    blocking = false,
    blockable = true,
    func = (function()
      for _, v in ipairs(G.seerea.cards) do
        if not v.states.visible then
          fakeMaterialize(v,{G.C.GOLD,G.C.BLUE,G.C.PURPLE})
        end
      end
      return true
    end)
  }))
end

--[[
  these are just adapted/reworked from the base start_dissolve and start_materialize Card methods
--]]
function fakeDissolve(c, dissolve_colours)
  local dissolve_time = 0.7
  c.dissolve = 0
  c.dissolve_colours = dissolve_colours
  G.E_MANAGER:add_event(Event({
      trigger = 'ease',
      blockable = false,
      ref_table = c,
      ref_value = 'dissolve',
      ease_to = 1,
      delay =  1*dissolve_time,
      func = (function(t) return t end)
  }))
  G.E_MANAGER:add_event(Event({
      trigger = 'after',
      blockable = false,
      delay =  1.051*dissolve_time,
      func = (function() c.states.visible = false; return true end)
  }))
end

function fakeMaterialize(c,dissolve_colours)
    local dissolve_time = 0.6
    c.states.visible = true
    c.states.hover.can = false
    c.dissolve = 1
    c.dissolve_colours = dissolve_colours
    G.E_MANAGER:add_event(Event({
        trigger = 'ease',
        blockable = false,
        ref_table = c,
        ref_value = 'dissolve',
        ease_to = 0,
        delay =  1*dissolve_time,
        func = (function(t) return t end)
    }))
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        blockable = false,
        delay =  1.05*dissolve_time
    }))
end

--[[
  whenever we draw from the deck to our hand, clear the seerea and refresh it with the future
--]]
local drawFromDeckToHandRef = G.FUNCS.draw_from_deck_to_hand
function G.FUNCS.draw_from_deck_to_hand(e)

  --clear the seerea
  hide_seerea()
  G.E_MANAGER:add_event(Event({
      trigger = 'after',
      blockable = false,
      delay =  1.05*0.7,
      func = function ()
        if G.seerea.cards then
          for j=#G.seerea.cards,1,-1 do
            G.seerea.cards[j]:remove()
          end
        end
        return true
      end
  }))
  drawFromDeckToHandRef(e)
  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.1,
    func = function()
      -- make sure if we have less than 8 cards in the deck, we only try to copy how many there are
      local card_count = math.min(#G.deck.cards, 8)
      if card_count > 0 then
        local future = {}
        for i=0,card_count-1 do
          table.insert(future, copy_card(G.deck.cards[#G.deck.cards-i], nil, 0.7, G.playing_card))
        end
        for _, v in ipairs(future) do
          v.greyed = true
          v.states.click.can = false
          if not G.HAS_MEDIUM then
            v.states.visible = false
          end
          G.seerea:emplace(v)
          v:hard_set_T()
          if G.HAS_MEDIUM then
            fakeMaterialize(v,{G.C.BLUE,G.C.PURPLE})
          end
        end
      end
      return true
    end
  }))
end

--

----------------------------------------------
------------MOD CODE END----------------------
