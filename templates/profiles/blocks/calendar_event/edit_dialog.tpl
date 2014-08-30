{$uniqid = uniqid()}
<div data-role="dialog" data-close-btn="right">
	<div data-role="header" data-theme="a">
		<h1>Edit</h1>
	</div>
	
	<div data-role="content">
		<h3 style="margin:0;white-space:normal;word-wrap:break-word;word-break:break-word;">{$calendar_event->name}</h3>
	
		<form id="frm{$uniqid}" method="post">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="handleProfileBlockRequest">
		<input type="hidden" name="extension" value="{MobileProfile_CalendarEvent::ID}">
		<input type="hidden" name="action" value="saveEditDialog">
		<input type="hidden" name="id" value="{$calendar_event->id}">
		<input type="hidden" name="do_delete" value="0">

		<div data-role="fieldcontain">
			<label for="frm-cerb-event-edit-name"> {'common.name'|devblocks_translate}:</label>
			<input type="text" name="name" id="frm-cerb-event-edit-name" value="{$calendar_event->name}" placeholder="Dinner" />
		</div>
		
		<div data-role="fieldcontain">
			<label for="frm-cerb-event-edit-datefrom"> Starting:</label>
			<input type="text" name="start" id="frm-cerb-event-edit-datefrom" value="{$calendar_event->date_start|devblocks_date}" placeholder="today 5pm" />
		</div>
		
		<div data-role="fieldcontain">
			<label for="frm-cerb-event-edit-dateto"> Ending:</label>
			<input type="text" name="end" id="frm-cerb-event-edit-dateto" value="{$calendar_event->date_end|devblocks_date}" placeholder="8pm" />
		</div>
		
		<div data-role="fieldcontain">
			<fieldset data-role="controlgroup" data-type="horizontal" data-mini="true">
				<legend>{'common.status'|devblocks_translate|capitalize}:</legend>
				
				<input type="radio" name="is_available" id="frm-cerb-event-isavailable-no" value="0" {if !$calendar_event->is_available}checked="checked"{/if}>
				<label for="frm-cerb-event-isavailable-no">busy</label>
				
				<input type="radio" name="is_available" id="frm-cerb-event-isavailable-yes" value="1" {if $calendar_event->is_available}checked="checked"{/if}>
				<label for="frm-cerb-event-isavailable-yes">available</label>
			</fieldset>
		</div>
		
		<button data-role="button" type="button" class="submit" data-theme="a">{'common.save_changes'|devblocks_translate|capitalize}</button>
		<button data-role="button" type="button" class="delete" data-theme="a">{'common.delete'|devblocks_translate|capitalize}</button>
	</div>
	
	<script type="text/javascript">
		var $frm = $('#frm{$uniqid}');
		
		$frm.find('button.submit').click(function(e) {
			var $this = $(this);
			
			$.mobile.loading('show');
			
			if($this.is('button.delete'))
				$frm.find('input:hidden[name=do_delete]').val('1');
			
			$.post(
				'{devblocks_url}ajax.php{/devblocks_url}',
				$frm.serialize(),
				function(json) {
					if(json.success) {
						window.history.go(-1);
						$.mobile.changePage(
							'{devblocks_url}c=m&a=profile&t={CerberusContexts::CONTEXT_CALENDAR_EVENT}&id={$dict->id}{/devblocks_url}',
							{
								allowSamePageTransition: true,
								transition: 'none',
								changeHash: false,
								showLoadMsg: true,
								reloadPage: true
							}
						);
					}
				}
			);
		});
		
		$frm.find('button.delete').click(function(e) {
			var $this = $(this);
			
			$.mobile.loading('show');
			
			$frm.find('input:hidden[name=do_delete]').val('1');
			
			$.post(
				'{devblocks_url}ajax.php{/devblocks_url}',
				$frm.serialize(),
				function(json) {
					if(json.success) {
						window.history.go(-2);
					}
				}
			);
		});
	</script>
</div>