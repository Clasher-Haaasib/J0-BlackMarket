let DATA = {};
let LOCALE = {};

const REPLY_KEYS = ['reply_show_what', 'reply_who_are_you', 'reply_nevermind'];
const FALLBACK = {
    select: "SELECT", back: "BACK", open: "OPEN", exit: "EXIT", reply: "REPLY", send: "SEND", cancel: "CANCEL",
    buy: "BUY", yes: "YES", no: "NO", contacts: "CONTACTS", stock_list: "STOCK LIST", confirm: "CONFIRM",
    market_closed: "MARKET CLOSED", come_back_between: "Come back between", typing: "TYPING...",
    dealer_what_need: "YO. WHAT YOU NEED?", reply_show_what: "SHOW ME WHAT YOU GOT", reply_who_are_you: "WHO ARE YOU?",
    reply_nevermind: "NEVERMIND", dealer_get_lost: "GET LOST THEN.", dealer_coords_sent: "COORDS SENT FOR {0}. CHECK YOUR GPS.",
    purchase: "PURCHASE", for_price: "FOR ${0}?"
};

function t(key, replacements) {
    let s = (LOCALE && LOCALE[key]) || FALLBACK[key] || key;
    if (replacements) for (const [k, v] of Object.entries(replacements)) s = s.replace(k, String(v));
    return s;
}

function getReplies() { return REPLY_KEYS.map(k => t(k)); }

let state = {
    view: 'CONTACTS',
    index: 0,
    contact: null,
    chat: [],
    typing: false,
    item: null
};

const $content = $('#main-content');

function isWithinOpenHours(hour24, openTime, closeTime) {
    if (openTime <= closeTime) return hour24 >= openTime && hour24 < closeTime;
    return hour24 >= openTime || hour24 < closeTime; // e.g. 22–06
}

function draw() {
    $content.html('');

    if (state.isClosed) {
        $('#btn-left').text('');
        $('#btn-right').text(t('exit'));
        const timeCfg = DATA.Time || {};
        const open = (timeCfg.OpenTime != null ? timeCfg.OpenTime : 10).toString().padStart(2, '0');
        const close = (timeCfg.CloseTime != null ? timeCfg.CloseTime : 18).toString().padStart(2, '0');
        $content.append(`
            <div class="view-header">${t('market_closed')}</div>
            <div style="text-align:center;padding:24px;font-size:14px;line-height:1.6">
                ${t('come_back_between')}<br><b>${open}:00 – ${close}:00</b>
            </div>
        `);
        return;
    }

    if (state.view === 'CONTACTS') {
        $('#btn-left').text(t('open'));
        $('#btn-right').text(t('exit'));

        $content.append(`<div class="view-header">${t('contacts')}</div>`);

        let list = $('<div class="item-list"></div>');
        (DATA.contacts || []).forEach((c,i)=>{
            list.append(`<div class="list-row ${state.index===i?'selected':''}">${c.name}</div>`);
        });
        $content.append(list);
    }

    if (state.view === 'CHAT') {
        $('#btn-left').text(t('reply'));
        $('#btn-right').text(t('back'));

        $content.append(`<div class="view-header">${state.contact.name}</div>`);

        let log = $('<div class="chat-log"></div>');
        state.chat.forEach(m=>{
            log.append(`<div class="bubble ${m.from}">${m.text}</div>`);
        });
        if (state.typing) log.append(`<div class="typing">${t('typing')}</div>`);
        $content.append(log);
        log.scrollTop(log[0].scrollHeight);
    }

    if (state.view === 'REPLY') {
        $('#btn-left').text(t('send'));
        $('#btn-right').text(t('cancel'));

        drawChatBg();

        let tray = $('<div class="action-tray"></div>');
        getReplies().forEach((r,i)=>{
            tray.append(`<div class="list-row ${state.index===i?'selected':''}">${r}</div>`);
        });
        $content.append(tray);
    }

    if (state.view === 'CATALOG') {
        $('#btn-left').text(t('buy'));
        $('#btn-right').text(t('back'));

        $content.append(`<div class="view-header">${t('stock_list')}</div>`);

        let list = $('<div class="item-list"></div>');
        (state.contact && state.contact.items || []).forEach((it,i)=>{
            list.append(`
                <div class="list-row ${state.index===i?'selected':''}">
                    <span>${it.name}</span>
                    <span>$${it.price}</span>
                </div>
            `);
        });
        $content.append(list);
    }

    if (state.view === 'CONFIRM') {
        $('#btn-left').text(t('yes'));
        $('#btn-right').text(t('no'));

        $content.append(`<div class="view-header">${t('confirm')}</div>`);
        $content.append(`
            <div style="text-align:center;padding:20px;font-size:14px">
                ${t('purchase')}<br>
                <b>${state.item.name}</b><br>
                ${t('for_price', { '${0}': state.item.price })}
            </div>
        `);
    }
}

function drawChatBg() {
    $content.append(`<div class="view-header">${state.contact.name}</div>`);
    let log = $('<div class="chat-log"></div>');
    state.chat.forEach(m=>{
        log.append(`<div class="bubble ${m.from}">${m.text}</div>`);
    });
    $content.append(log);
    log.scrollTop(log[0].scrollHeight);
}

function input(key) {
    if (state.isClosed) {
        if (['Backspace','Escape','q','Q','a','A'].includes(key)) {
            document.querySelector('body').style.display = 'none';
            $.post(`https://${GetParentResourceName()}/closeUi`, JSON.stringify({}));
        }
        return;
    }

    let up = ['w','W','ArrowUp'];
    let down = ['s','S','ArrowDown'];
    let ok = ['Enter','e','E','d','D'];
    let back = ['Backspace','Escape','q','Q','a','A'];

    let max = 0;
    if (state.view === 'CONTACTS') max = (DATA.contacts || []).length;
    if (state.view === 'REPLY') max = getReplies().length;
    if (state.view === 'CATALOG') max = (state.contact && state.contact.items || []).length;

    if (up.includes(key) && max)
        state.index = state.index>0 ? state.index-1 : max-1;

    if (down.includes(key) && max)
        state.index = state.index<max-1 ? state.index+1 : 0;

    if (ok.includes(key)) {
        if (state.view === 'CONTACTS') {
            state.contact = (DATA.contacts || [])[state.index];
            state.chat = [{from:'dealer',text: t('dealer_what_need')}];
            state.view = 'CHAT';
            state.index = 0;
        }
        else if (state.view === 'CHAT') {
            state.view = 'REPLY';
            state.index = 0;
        }
        else if (state.view === 'REPLY') {
            let replyText = getReplies()[state.index];
            state.chat.push({from:'me',text: replyText});
            state.view = 'CHAT';
            state.typing = true;

            if (state.index === 0) {
                setTimeout(()=>{
                    state.typing = false;
                    state.view = 'CATALOG';
                    state.index = 0;
                    draw();
                },1500);
                return;
            }

            setTimeout(()=>{
                state.typing = false;
                state.chat.push({from:'dealer',text: t('dealer_get_lost')});
                draw();
            },1000);
        }
        else if (state.view === 'CATALOG') {
            state.item = (state.contact && state.contact.items || [])[state.index];
            state.view = 'CONFIRM';
        }
        else if (state.view === 'CONFIRM') {
            state.chat.push({
                from:'dealer',
                text: t('dealer_coords_sent', {'{0}': state.item.name})
            });
            state.view = 'CHAT';
        }
    }

    if (back.includes(key)) {
        if (state.view === 'CHAT') state.view = 'CONTACTS';
        else if (state.view === 'REPLY') state.view = 'CHAT';
        else if (state.view === 'CATALOG') state.view = 'CHAT';
        else if (state.view === 'CONFIRM') state.view = 'CATALOG';
        state.index = 0;
    }

    draw();
}

$(window).on('keydown', e => input(e.key));


window.addEventListener('keydown', e => {
    if (e.key === 'Escape') {
        document.querySelector('body').style.display = 'none';
        $.post(`https://${GetParentResourceName()}/closeUi`, JSON.stringify({}));
    }
});

function updateClock() {
    fetch(`https://${GetParentResourceName()}/getTime`, {
        method: 'POST',
        body: JSON.stringify({})
    }).then(r => r.json()).then(data => {
        if (data && data.hour24 != null && data.minute != null) {
            $('#clock').text(
                data.hour24.toString().padStart(2, '0') + ':' +
                data.minute.toString().padStart(2, '0')
            );
        }
    }).catch(() => {});
}
updateClock();
setInterval(updateClock, 1000);

window.addEventListener('message', function(event) {
    if (event.data.action === 'openBurnerPhone') {
        document.querySelector('body').style.display = 'flex';
        DATA = event.data.data || {};
        LOCALE = event.data.locale || {};
        state = { view: 'CONTACTS', index: 0, contact: null, chat: [], typing: false, item: null, isClosed: false };

        const timeCfg = DATA.Time;
        if (timeCfg && timeCfg.Enabled) {
            fetch(`https://${GetParentResourceName()}/getTime`, { method: 'POST', body: JSON.stringify({}) })
                .then(r => r.json())
                .then(data => {
                    const hour = data && data.hour24 != null ? data.hour24 : 12;
                    state.isClosed = !isWithinOpenHours(hour, timeCfg.OpenTime ?? 10, timeCfg.CloseTime ?? 18);
                    draw();
                })
                .catch(() => { state.isClosed = false; draw(); });
        } else {
            draw();
        }
    }
});

