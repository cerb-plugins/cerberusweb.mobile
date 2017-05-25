{$msg_id = uniqid()}
<div class="bot-chat-object" id="{$msg_id}" data-delay-ms="{$delay_ms|default:0}">
{$script nofilter}
<script type="text/javascript">
$(function() {
	var $msg = $('#{$msg_id}');
	$msg.enhanceWithin();
});
</script>
</div>