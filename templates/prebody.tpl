{if $active_worker->id}

{$uniqid = uniqid()}

<div id="div{$uniqid}" style="width:100%;display:none;background-color:white;padding:10px 10px 0px 10px;margin:10px 0px 10px 0px;border-radius:5px;font-size:3em;">

	<img src="{devblocks_url}c=resource&p=cerberusweb.mobile&f=plugin.png{/devblocks_url}" align="left" />
	
	<h2>Try the mobile interface</h2>
	
	<div>
		You're currently using a small screen.  Would you like to switch to the mobile interface for an optimized experience?
	</div>
	
	<div>
		<form action="javascript:;">
		<button type="button" class="mobile-switch" style="font-size:3em;padding:20px">Switch to mobile</button>
		 &nbsp; 
		<button type="button" class="mobile-cancel" style="font-size:3em;padding:20px;">No thanks</button>
		</form>
	</div>

</div>

<script type="text/javascript">
$(function() {
	// Offer the mobile interface to small screened devices
	
	var width = window.screen.width;
	var $mobile_tip = $('#div{$uniqid}');
	
	$mobile_tip.find('button.mobile-switch').click(function(e) {
		document.location.href = '{devblocks_url}c=m{/devblocks_url}';
	});
	
	$mobile_tip.find('button.mobile-cancel').click(function(e) {
		$mobile_tip.remove();
		
		if(sessionStorage)
			sessionStorage.hide_mobile_tip = true;
	});
	
	if(sessionStorage && !sessionStorage.hide_mobile_tip && width < 500) {
		$mobile_tip.dialog({ modal: true, width: document.width-25, drag: false, resizable: false, show: true });
	}
	
	// Add a mobile interface option to the worker menu
	
	var $worker_menu = $('#menuSignedIn');
	var $signout_item = $worker_menu.find('a[href="{devblocks_url}c=login&a=signout{/devblocks_url}"]').closest('li');
	var $mobile_item = $('<li><a href="{devblocks_url}c=m{/devblocks_url}">switch to mobile</a></li>');
	$mobile_item.insertBefore($signout_item);
});
</script>

{/if}