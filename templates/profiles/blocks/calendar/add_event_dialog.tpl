{$uniqid = uniqid()}
<div data-role="dialog" data-close-btn="right">
	<div data-role="header" data-theme="f">
		<h1>Add Event</h1>
	</div>
	
	<div data-role="content">
		<h3 style="margin:0;white-space:normal;word-wrap:break-word;word-break:break-word;">{$calendar->name}</h3>
	
		<form id="frm{$uniqid}" method="post">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="handleProfileBlockRequest">
		<input type="hidden" name="extension" value="{MobileProfile_Calendar::ID}">
		<input type="hidden" name="action" value="saveAddEventDialog">
		<input type="hidden" name="id" value="{$calendar->id}">

		<div data-role="fieldcontain">
			<label for="frm-cerb-event-add-name"> {'common.name'|devblocks_translate}:</label>
			<input type="text" name="name" id="frm-cerb-event-add-name" value="" placeholder="Dinner" />
		</div>
		
		<div data-role="fieldcontain">
			<label for="frm-cerb-event-add-datefrom"> Starting:</label>
			<input type="text" name="start" id="frm-cerb-event-add-datefrom" value="" placeholder="today 5pm" />
		</div>
		
		<div data-role="fieldcontain">
			<label for="frm-cerb-event-add-dateto"> Ending:</label>
			<input type="text" name="end" id="frm-cerb-event-add-dateto" value="" placeholder="8pm" />
		</div>
		
		<div data-role="fieldcontain">
			<fieldset data-role="controlgroup" data-type="horizontal" data-mini="true">
				<legend>{'common.status'|devblocks_translate|capitalize}:</legend>
				
				<input type="radio" name="is_available" id="frm-cerb-event-isavailable-no" value="0" >
				<label for="frm-cerb-event-isavailable-no">busy</label>
				
				<input type="radio" name="is_available" id="frm-cerb-event-isavailable-yes" value="1">
				<label for="frm-cerb-event-isavailable-yes">available</label>
			</fieldset>
		</div>
		
		<button data-role="button" type="button" class="submit" data-theme="f">{'common.save_changes'|devblocks_translate|capitalize}</button>
	</div>
	
	<script type="text/javascript">
		var $frm = $('#frm{$uniqid}');
		
		$frm.find('button.submit').click(function(e) {
			$.mobile.loading('show');
			
			$.post(
				'{devblocks_url}ajax.php{/devblocks_url}',
				$frm.serialize(),
				function(json) {
					if(json.success) {
						jQuery.mobile.changePage(window.location.href, {
							allowSamePageTransition: true,
							transition: 'none',
							reloadPage: true
						});
					}
				}
			);
		});
	</script>
</div>