$(".chat-message-list").ready(function() {
  var messageTemplate = $("#chat-message-template").html();

  $(".chat-message-list").scroll(function(){
    if($(this).scrollTop() === 0){
      fetch_chat_messages();
    }
  });

  $("#new-message-form").on('submit', function () {
    create_new_message();
    clear_msg_input();

    return false;
  });

  App = setup_action_cable_app();
  console.log(App);

  function create_new_message() {
    const msg = $(".msg-input").val();
    const chat_id = get_chat_id();
    const url = "/chat_messages.json";
    $.post(url, { chat_message: { message: msg, chat_id: chat_id } }, function(data, status) {
      //console.log(data);
      console.log(`msg create status = ${status}`);
    });
  }

  function clear_msg_input() {
    $(".msg-input").val('');
  }

  function setup_action_cable_app() {
    const chatId = get_chat_id();
    if (isNaN(chatId)) {
      return {};
    }

    let App = {};
    const hostname = get_hostname_with_port();
    const prefix = (window.location.hostname === 'localhost') ? 'ws' : 'wss';
    const url = `${prefix}://${hostname}/cable?chat_id=${chatId}`;
    App.cable = ActionCable.createConsumer(url);

    App.messages = App.cable.subscriptions.create({channel: 'MessagesChannel', chat_id: chatId}, {
      received: handle_msg_received,
    });

    return App;
  }

  function handle_msg_received(data) {
    const elem = generate_chat_message_element(data);
    $("ul.chat-message-list").append(elem);
  }

  function get_hostname_with_port() {
    let hostname = window.location.hostname;
    const port = window.location.port;
    if (port) {
      hostname += `:${port}`;
    }
    return hostname;
  }

  function fetch_chat_messages() {
    if (!has_more_message()) {
      return;
    }

    const next_page = get_next_page_num();
    const url = `${window.location.href}.json?page=${next_page}`;

    $.getJSON(url, function(data) {
      const elems = data.map(function(e) {
        return generate_chat_message_element(e);
      });
      $("ul.chat-message-list").prepend(elems);

      const has_more_message = data.length > 0
      update_page_info(next_page, has_more_message)
    });
  }

  function update_page_info(page_num, has_more_message) {
    $("#page-info").data("page", page_num);
    $("#page-info").data("has-more-message", has_more_message);
  }

  function get_next_page_num() {
    const last_page = parseInt($("#page-info").data("page"));
    return last_page + 1;
  }

  function get_chat_id() {
    const chat_id = parseInt($("#page-info").data("chatId"));
    return chat_id;
  }

  function has_more_message() {
    const i = $("#page-info").data("hasMoreMessage");
    return i;
  }

  function generate_chat_message_element(chat_msg) {
    var rendered = Mustache.render(messageTemplate, chat_msg);
    return rendered;
  }
});


