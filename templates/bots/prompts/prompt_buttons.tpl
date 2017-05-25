{$msg_id = uniqid()}
<div class="bot-chat-object" data-delay-ms="{$delay_ms|default:0}" data-typing-indicator="true" id="{$msg_id}">
	<div class="bot-chat-message bot-chat-right">
		<div class="bot-chat-message-bubble" style="background-color:white;">
			{$mid = round(count($options)/2)}
			{$color_from = $color_from|default:'#FFFFFF'}
			{$color_to = $color_to|default:$color_from}
			{$color_mid = $color_mid|default:$color_from}
			
			{$colors = array_fill(0, count($options), '#FFFFFF')}
			{$colors[0] = $color_from}
			{$colors[count($options)-1] = $color_to}
			{if !empty($color_mid) && $color_mid != '#FFFFFF'}
				{if 0 == count($options) % 2}
					{$mid = ceil(count($options)/2)}
				{else}
					{$mid = floor(count($options)/2)}
				{/if}
				{$colors[$mid] = $color_mid}
			{/if}
			{$colors = DevblocksPlatform::colorLerpArray($colors)}
			
			{foreach from=$options item=option name=options}
			{$idx = $smarty.foreach.options.iteration}
			{$color = $colors[$smarty.foreach.options.index]}
			<button type="button" class="bot-chat-button" style="{if $color && $color != '#FFFFFF'}background:none;background-color:{$color};{/if}{if $style}{$style}{/if}" value="{$option}">
				{$option}
			</button>
			{/foreach}
		</div>
	</div>
	
	<br clear="all">
	
	<script type="text/javascript">
	$(function() {
		var $msg = $('#{$msg_id}');
		var $chat_window_input_form = $msg.closest('form');
		var $convo = $chat_window_input_form.find('.bot-chat-window-convo');
		var $chat_input = $chat_window_input_form.find('input[name=message]');
		
		$msg.find('button.bot-chat-button')
			.click(function() {
				var $button = $(this);
				
				var txt = $button.val();
				
				$chat_input.val(txt);
				$convo.trigger('cerb-send-message');
				$msg.remove();
			})
			.first()
			.focus()
		;
	});
	</script>
</div>
