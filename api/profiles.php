<?php
abstract class Extension_MobileProfileBlock extends DevblocksExtension {
	static function getAll($as_instances=false, $with_contexts=null) {
		if(!is_null($with_contexts) && !is_array($with_contexts))
			$with_contexts = array($with_contexts);
		
		$extensions = DevblocksPlatform::getExtensions('mobile.profile.block', true);
		
		if(is_array($with_contexts))
		foreach($extensions as $extension_id => $extension) {
			$allowed_contexts = array();
			
			if($as_instances) {
				$allowed_contexts = array_keys($extension->manifest->params['contexts'][0]);
			} else {
				$allowed_contexts = array_keys($extension->params['contexts'][0]);
			}
			
			foreach($with_contexts as $context) {
				if(!in_array($context, $allowed_contexts)) {
					unset($extensions[$extension_id]);
					continue;
				}
			}
		}
		
		return $extensions;
	}
	
	/**
	 * @param unknown_type $context
	 * @return Extension_DevblocksContext
	 */
	public static function get($id) {
		static $extensions = null;
		
		if(isset($extensions[$id]))
			return $extensions[$id];
		
		if(!isset($extensions[$id])) {
			if(null == ($ext = DevblocksPlatform::getExtension($id, true)))
				return;
			
			if(!($ext instanceof Extension_MobileProfileBlock))
				return;
			
			$extensions[$id] = $ext;
			return $ext;
		}
	}
	
	abstract function render(DevblocksDictionaryDelegate $dict);
};

if(class_exists('Extension_MobileProfileBlock')):
class MobileProfile_Calendar extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.calendar';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/calendar.tpl');
	}
	
	function calendarPageAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$month  = DevblocksPlatform::importGPC($_REQUEST['month'], 'integer', 0);
		@$year  = DevblocksPlatform::importGPC($_REQUEST['year'], 'integer', 0);
		
		$active_worker = CerberusApplication::getActiveWorker();
		$visit = CerberusApplication::getVisit();
		$tpl = DevblocksPlatform::getTemplateService();
		
		$tpl->assign('month', $month);
		$tpl->assign('year', $year);
		
		CerberusContexts::getContext(CerberusContexts::CONTEXT_CALENDAR, $id, $labels, $values);
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Remember the month/year for this calendar
		$visit->set(sprintf('calendar_%d_monthyear', $id), array('month'=>$month, 'year'=>$year));
		
		$tpl->display('devblocks:cerberusweb.mobile::calendars/calendar.tpl');
	}
	
	function showAddEventDialogAction() {
		@$calendar_id  = DevblocksPlatform::importGPC($_REQUEST['calendar_id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		$active_worker = CerberusApplication::getActiveWorker();
		
		if(false == ($calendar = DAO_Calendar::get($calendar_id)))
			return;
		
		if(!Context_Calendar::isWriteableByActor($calendar, $active_worker))
			return;
		
		if(!isset($calendar->params['manual_disabled']) || !empty($calendar->params['manual_disabled']))
			return;
		
		$tpl->assign('calendar', $calendar);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/calendar/add_event_dialog.tpl');
	}
	
	function saveAddEventDialogAction() {
		@$calendar_id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$name = DevblocksPlatform::importGPC($_REQUEST['name'], 'string', '');
		@$is_available = DevblocksPlatform::importGPC($_REQUEST['is_available'], 'integer', 0);
		@$start = DevblocksPlatform::importGPC($_REQUEST['start'], 'string', '');
		@$end = DevblocksPlatform::importGPC($_REQUEST['end'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		if(false == ($calendar = DAO_Calendar::get($calendar_id)))
			return;
		
		if(!Context_Calendar::isWriteableByActor($calendar, $active_worker))
			return;
		
		if(!isset($calendar->params['manual_disabled']) || !empty($calendar->params['manual_disabled']))
			return;

		@$start = strtotime($start);
		@$end = strtotime($end, $start);
		
		$event_id = DAO_CalendarEvent::create(array(
			DAO_CalendarEvent::CALENDAR_ID => $calendar->id,
			DAO_CalendarEvent::NAME => $name,
			DAO_CalendarEvent::IS_AVAILABLE => $is_available,
			DAO_CalendarEvent::DATE_START => intval($start),
			DAO_CalendarEvent::DATE_END => intval($end),
		));
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
			'event_id' => $event_id,
		));
	}
};

class MobileProfile_CalendarEvent extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.calendar_event';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/calendar_event.tpl');
	}
	
	function showEditDialogAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		$active_worker = CerberusApplication::getActiveWorker();
		
		if(false == ($calendar_event = DAO_CalendarEvent::get($id)))
			return;
		
		if(false == ($calendar = DAO_Calendar::get($calendar_event->calendar_id)))
			return;
		
		if(!Context_Calendar::isWriteableByActor($calendar, $active_worker))
			return;
		
		if(!isset($calendar->params['manual_disabled']) || !empty($calendar->params['manual_disabled']))
			return;
		
		$tpl->assign('calendar', $calendar);
		$tpl->assign('calendar_event', $calendar_event);
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/calendar_event/edit_dialog.tpl');
	}
	
	function saveEditDialogAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$name = DevblocksPlatform::importGPC($_REQUEST['name'], 'string', '');
		@$is_available = DevblocksPlatform::importGPC($_REQUEST['is_available'], 'integer', 0);
		@$start = DevblocksPlatform::importGPC($_REQUEST['start'], 'string', '');
		@$end = DevblocksPlatform::importGPC($_REQUEST['end'], 'string', '');
		@$do_delete = DevblocksPlatform::importGPC($_REQUEST['do_delete'], 'integer', 0);
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		if(false == ($calendar_event = DAO_CalendarEvent::get($id)))
			return;
		
		if(false == ($calendar = DAO_Calendar::get($calendar_event->calendar_id)))
			return;
		
		if(!Context_Calendar::isWriteableByActor($calendar, $active_worker))
			return;
		
		if(!isset($calendar->params['manual_disabled']) || !empty($calendar->params['manual_disabled']))
			return;

		if(!empty($do_delete)) {
			DAO_CalendarEvent::delete($id);
			
		} else {
			@$start = strtotime($start);
			@$end = strtotime($end, $start);
			
			$fields = array(
				DAO_CalendarEvent::NAME => $name,
				DAO_CalendarEvent::IS_AVAILABLE => $is_available,
				DAO_CalendarEvent::DATE_START => intval($start),
				DAO_CalendarEvent::DATE_END => intval($end),
			);
			
			$changed_fields = Cerb_ORMHelper::uniqueFields($fields, $calendar_event);
			
			if(!empty($changed_fields))
				DAO_CalendarEvent::update($id, $changed_fields);
		}
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
	}
};

class MobileProfile_EmailAddress extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.email_address';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/address.tpl');
	}
	
	function showEditDialogAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_ADDRESS, $id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/address/edit_dialog.tpl');
		exit;
	}
	
	function saveEditDialogAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$org_name = DevblocksPlatform::importGPC($_REQUEST['org'], 'string', '');
		@$is_banned = DevblocksPlatform::importGPC($_REQUEST['is_banned'], 'integer', 0);
		@$is_defunct = DevblocksPlatform::importGPC($_REQUEST['is_defunct'], 'integer', 0);
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$fields = array();
		
		// Fields
		
		$fields[DAO_Address::IS_BANNED] = $is_banned;
		$fields[DAO_Address::IS_DEFUNCT] = $is_defunct;
		
		if(!empty($org_name) && false !== ($org_id = DAO_ContactOrg::lookup($org_name, true))) {
			if(false !== ($org = DAO_ContactOrg::get($org_id)))
				$fields[DAO_Address::CONTACT_ORG_ID] = $org_id;
		}
		
		// DAO
		
		DAO_Address::update($id, $fields);

		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
		
		exit;
	}
	
	function viewSearchTicketsAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		if(false == ($address = DAO_Address::get($id)))
			return;
		
		$context_ext = Extension_DevblocksContext::get(CerberusContexts::CONTEXT_TICKET);
		
		$view = $context_ext->getSearchView(); /* @var $view C4_AbstractView */
		
		$view->addParams(array(
			new DevblocksSearchCriteria(SearchFields_Ticket::REQUESTER_ADDRESS, '=', $address->email)
		), true);
		
		$view->renderSortBy = SearchFields_Ticket::TICKET_UPDATED_DATE;
		$view->renderSortAsc = false;
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
	}
};

class MobileProfile_Message extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.message';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/message.tpl');
	}
};

class MobileProfile_Notification extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.notification';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/notification.tpl');
	}
	
	function markReadAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);

		if(false == ($notification = DAO_Notification::get($id)))
			return;
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		if($notification->worker_id != $active_worker->id)
			return;
		
		$notification->markRead();
		
		echo json_encode(array(
			'success' => true,
		));
	}
};

class MobileProfile_Org extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.org';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/org.tpl');
	}
	
	function showEditDialogAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_ORG, $id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/org/edit_dialog.tpl');
		exit;
	}
	
	function saveEditDialogAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$name = DevblocksPlatform::importGPC($_REQUEST['name'], 'string', '');
		@$street = DevblocksPlatform::importGPC($_REQUEST['street'], 'string', '');
		@$city = DevblocksPlatform::importGPC($_REQUEST['city'], 'string', '');
		@$province = DevblocksPlatform::importGPC($_REQUEST['province'], 'string', '');
		@$postal = DevblocksPlatform::importGPC($_REQUEST['postal'], 'string', '');
		@$country = DevblocksPlatform::importGPC($_REQUEST['country'], 'string', '');
		@$phone = DevblocksPlatform::importGPC($_REQUEST['phone'], 'string', '');
		@$website = DevblocksPlatform::importGPC($_REQUEST['website'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$fields = array();
		
		// Fields
		
		$fields[DAO_ContactOrg::NAME] = $name;
		$fields[DAO_ContactOrg::STREET] = $street;
		$fields[DAO_ContactOrg::CITY] = $city;
		$fields[DAO_ContactOrg::PROVINCE] = $province;
		$fields[DAO_ContactOrg::POSTAL] = $postal;
		$fields[DAO_ContactOrg::COUNTRY] = $country;
		$fields[DAO_ContactOrg::PHONE] = $phone;
		$fields[DAO_ContactOrg::WEBSITE] = $website;
		
		// DAO
		
		DAO_ContactOrg::update($id, $fields);

		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
		
		exit;
	}
	
	function viewSearchContactsAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		if(false == ($org = DAO_ContactOrg::get($id)))
			return;
		
		$context_ext = Extension_DevblocksContext::get(CerberusContexts::CONTEXT_ADDRESS);
		
		$view = $context_ext->getSearchView(); /* @var $view C4_AbstractView */
		
		$view->addParams(array(
			new DevblocksSearchCriteria(SearchFields_Address::ORG_NAME, '=', $org->name)
		), true);
		
		$view->renderSortBy = SearchFields_Address::NUM_NONSPAM;
		$view->renderSortAsc = false;
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
	}
	
	function viewSearchTicketsAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		if(false == ($org = DAO_ContactOrg::get($id)))
			return;
				
		$context_ext = Extension_DevblocksContext::get(CerberusContexts::CONTEXT_TICKET);
		
		$view = $context_ext->getSearchView(); /* @var $view C4_AbstractView */
		
		$view->addParams(array(
			new DevblocksSearchCriteria(SearchFields_Ticket::ORG_NAME, '=', $org->name)
		), true);
		
		$view->renderSortBy = SearchFields_Ticket::TICKET_UPDATED_DATE;
		$view->renderSortAsc = false;
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
	}
};

class MobileProfile_Task extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.task';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/task.tpl');
	}
	
	function showEditDialogAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_TASK, $id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/task/edit_dialog.tpl');
		exit;
	}
	
	function saveEditDialogAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$title = DevblocksPlatform::importGPC($_REQUEST['title'], 'string', '');
		@$status = DevblocksPlatform::importGPC($_REQUEST['status'], 'string', '');
		@$due_date = DevblocksPlatform::importGPC($_REQUEST['due_date'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$fields = array();
		
		// Title
		
		if(!empty($title))
			$fields[DAO_Task::TITLE] = $title;
		
		// Status
		
		switch($status) {
			case 'active':
				$fields[DAO_Task::IS_COMPLETED] = 0;
				$fields[DAO_Task::COMPLETED_DATE] = 0;
				break;
				
			case 'completed':
				$fields[DAO_Task::IS_COMPLETED] = 1;
				$fields[DAO_Task::COMPLETED_DATE] = time();
				break;
		}
		
		// Due date
		
		$fields[DAO_Task::DUE_DATE] = intval(@strtotime($due_date));
		
		// DAO
		
		DAO_Task::update($id, $fields);

		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
		
		exit;
	}
};

class MobileProfile_Ticket extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.ticket';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		
		/*
		// Show ticket messages
		$defaults = C4_AbstractViewModel::loadFromClass('View_Message');
		$defaults->id = '';
		$defaults->is_ephemeral = true;
		
		if(false != ($view = C4_AbstractViewLoader::getView('mobile_profile_ticket_messages', $defaults))) {
			$view->addParamsRequired(array(
				new DevblocksSearchCriteria(SearchFields_Message::TICKET_ID, '=', $dict->id)
			), true);
			
			$view->renderSortBy = SearchFields_Message::CREATED_DATE;
			$view->renderSortAsc = false;
			$view->renderPage = 0;
			$view->renderLimit = 10;
			$view->renderTotal = true;
			
			// [TODO] Overload the default properties for the messages worklist (e.g. no need to see ticket listed every time)
			
			$tpl->assign('view', $view);
		}
		*/
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket.tpl');
	}
	
	function showEditDialogAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_TICKET, $id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);

		// Groups
		
		$groups = DAO_Group::getAll();
		$tpl->assign('groups', $groups);
		
		$buckets = DAO_Bucket::getAll();
		$tpl->assign('buckets', $buckets);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket/edit_dialog.tpl');
		exit;
	}
	
	function saveEditDialogAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$reopen_at = DevblocksPlatform::importGPC($_REQUEST['reopen_at'], 'string', '');
		@$status = DevblocksPlatform::importGPC($_REQUEST['status'], 'string', '');
		@$group_id = DevblocksPlatform::importGPC($_REQUEST['group_id'], 'integer', 0);
		@$bucket_id = DevblocksPlatform::importGPC($_REQUEST['bucket_id'], 'integer', 0);
		@$owner_id = DevblocksPlatform::importGPC($_REQUEST['owner_id'], 'integer', 0);
		@$spam_training = DevblocksPlatform::importGPC($_REQUEST['spam_training'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		if(false == ($ticket = DAO_Ticket::get($id)))
			return;
		
		$fields = array();

		// Spam training
		if(!empty($spam_training)) {
			if($spam_training == 'S')
				CerberusBayes::markTicketAsSpam($id);
			elseif($spam_training == 'N')
				CerberusBayes::markTicketAsNotSpam($id);
		}
		
		// [TODO] Check permissions
		if($status == 'deleted') {
			$fields[DAO_Ticket::STATUS_ID] = Model_Ticket::STATUS_DELETED;
			$fields[DAO_Ticket::REOPEN_AT] = 0;
			
		} else {
			
			// Move
			if(!empty($group_id)
				&& false !== DAO_Group::get($group_id)
				&& false !== DAO_Bucket::get($bucket_id)) {
					$fields[DAO_Ticket::GROUP_ID] = $group_id;
					$fields[DAO_Ticket::BUCKET_ID] = $bucket_id;
			}
			
			// Owner
			$fields[DAO_Ticket::OWNER_ID] = $owner_id;
			
			// Status
			switch($status) {
				case 'open':
					$fields[DAO_Ticket::STATUS_ID] = Model_Ticket::STATUS_OPEN;
					$fields[DAO_Ticket::REOPEN_AT] = 0;
					break;
					
				case 'waiting':
					$fields[DAO_Ticket::STATUS_ID] = Model_Ticket::STATUS_WAITING;
					$fields[DAO_Ticket::REOPEN_AT] = intval(@strtotime($reopen_at));
					break;
					
				case 'closed':
					$fields[DAO_Ticket::STATUS_ID] = Model_Ticket::STATUS_CLOSED;
					$fields[DAO_Ticket::REOPEN_AT] = intval(@strtotime($reopen_at));
					break;
			}
		}
		
		// Only update fields that changed
		$fields = Cerb_ORMHelper::uniqueFields($fields, $ticket);

		if(!empty($fields))
			DAO_Ticket::update($id, $fields);

		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
		
		exit;
	}
	
	function showReplyDialogAction() {
		@$message_id  = DevblocksPlatform::importGPC($_REQUEST['message_id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_MESSAGE, $message_id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket/reply_dialog.tpl');
		exit;
	}
	
	function saveReplyDialogAction() {
		@$message_id = DevblocksPlatform::importGPC($_REQUEST['reply_to_message_id'], 'integer', 0);
		@$raw_content = DevblocksPlatform::importGPC($_REQUEST['content'], 'string', '');
		@$reopen_at = DevblocksPlatform::importGPC($_REQUEST['reopen_at'], 'string', '');
		@$status = DevblocksPlatform::importGPC($_REQUEST['status'], 'string', '');
		
		header('Content-type: application/json');
		
		try {
			$active_worker = CerberusApplication::getActiveWorker();
			
			if(false == ($ticket = DAO_Ticket::getTicketByMessageId($message_id)))
				return false;
			
			$content = '';
			$commands = array();
			
			$message_properties = array(
				'message_id' => $message_id,
				'status_id' => intval(array_search($status, array('open','waiting','closed','deleted'))),
				'ticket_reopen' => ($status != 'open') ? $reopen_at : 0,
				'content' => $raw_content,
				'worker_id' => $active_worker->id,
			);
			
			$this->_parseReplyHashCommands($ticket, $active_worker, $message_properties, $commands);
			
			$new_message_id = CerberusMail::sendTicketMessage($message_properties);
			
			if(!empty($commands))
				$this->_handleReplyHashCommands($commands, $ticket, $active_worker);
			
			echo json_encode(array(
				'success' => true,
				'message_id' => $new_message_id,
				'ticket_id' => $ticket->id,
			));
			
		} catch (Exception $e) {
			echo json_encode(array(
				'success' => false,
				'error' => 'An error occurred.',
			));
			
		}
		
		exit;
	}
	
	private function _parseReplyHashCommands(Model_Ticket $ticket, Model_worker $worker, array &$message_properties, array &$commands) {
		$lines_in = DevblocksPlatform::parseCrlfString($message_properties['content'], true);
		$lines_out = array();
		
		$is_cut = false;
		
		foreach($lines_in as $line) {
			$handled = false;
			
			if(preg_match('/^\#([A-Za-z0-9_]+)(.*)$/', $line, $matches)) {
				@$command = $matches[1];
				@$args = ltrim($matches[2]);
				
				switch($command) {
					case 'attach':
						@$bundle_tag = $args;
						$handled = true;
						
						if(empty($bundle_tag))
							break;
						
						if(false == ($bundle = DAO_FileBundle::getByTag($bundle_tag)))
							break;
						
						$attachments = $bundle->getAttachments();
						
						$message_properties['link_forward_files'] = true;
						
						if(!isset($message_properties['forward_files']))
							$message_properties['forward_files'] = array();
						
						$message_properties['forward_files'] = array_merge($message_properties['forward_files'], array_keys($attachments));
						break;
					
					case 'cut':
						$is_cut = true;
						$handled = true;
						break;
						
					case 'signature':
						$group = $ticket->getGroup();
						$line = $group->getReplySignature($ticket->bucket_id, $worker);
						break;
						
					default:
						$commands[] = array(
							'command' => $command,
							'args' => $args,
						);
						$handled = true;
						break;
				}
			}
			
			if(!$handled && !$is_cut) {
				$lines_out[] = $line;
			}
		}
		
		$message_properties['content'] = implode("\n", $lines_out);
	}
	
	private function _handleReplyHashCommands(array $commands, Model_Ticket $ticket, Model_Worker $worker) {
		foreach($commands as $command_data) {
			switch($command_data['command']) {
				case 'comment':
					@$comment = $command_data['args'];
					
					if(!empty($comment)) {
						$also_notify_worker_ids = array_keys(CerberusApplication::getWorkersByAtMentionsText($comment));
						
						$fields = array(
							DAO_Comment::CONTEXT => CerberusContexts::CONTEXT_TICKET,
							DAO_Comment::CONTEXT_ID => $ticket->id,
							DAO_Comment::OWNER_CONTEXT => CerberusContexts::CONTEXT_WORKER,
							DAO_Comment::OWNER_CONTEXT_ID => $worker->id,
							DAO_Comment::CREATED => time()+2,
							DAO_Comment::COMMENT => $comment,
						);
						$comment_id = DAO_Comment::create($fields, $also_notify_worker_ids);
					}
					break;
		
				case 'watch':
					CerberusContexts::addWatchers(CerberusContexts::CONTEXT_TICKET, $ticket->id, array($worker->id));
					break;
		
				case 'unwatch':
					CerberusContexts::removeWatchers(CerberusContexts::CONTEXT_TICKET, $ticket->id, array($worker->id));
					break;
			}
		}
	}
	
	function showRelayDialogAction() {
		@$message_id  = DevblocksPlatform::importGPC($_REQUEST['message_id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);
		
		CerberusContexts::getContext(CerberusContexts::CONTEXT_MESSAGE, $message_id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);

		// Relay addresses
		
		$workers_with_relays = DAO_AddressToWorker::getByWorkers();
		$tpl->assign('workers_with_relays', $workers_with_relays);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket/relay_dialog.tpl');
		exit;
	}
	
	function saveRelayDialogAction() {
		@$ticket_id = DevblocksPlatform::importGPC($_REQUEST['ticket_id'], 'integer', 0);
		@$message_id = DevblocksPlatform::importGPC($_REQUEST['message_id'], 'integer', 0);
		@$emails = DevblocksPlatform::importGPC($_REQUEST['emails'], 'array', array());
		@$include_attachments = DevblocksPlatform::importGPC($_REQUEST['include_attachments'], 'integer', 0);
		
		$active_worker = CerberusApplication::getActiveWorker();

		header('Content-type: application/json');
		
		try {
			CerberusMail::relay($message_id, $emails, $include_attachments, null, CerberusContexts::CONTEXT_WORKER, $active_worker->id);
			
			echo json_encode(array(
				'success' => true,
			));
			
		} catch(Exception $e) {
			echo json_encode(array(
				'success' => false,
			));
		}
		
		exit;
	}
	
	function viewSearchMessagesAction() {
		@$ticket_id = DevblocksPlatform::importGPC($_REQUEST['ticket_id'], 'integer', 0);
		
		$ticket = DAO_Ticket::get($ticket_id);
		
		$context_ext = Extension_DevblocksContext::get(CerberusContexts::CONTEXT_MESSAGE);
		$view = $context_ext->getSearchView(); /* @var $view C4_AbstractView */
		$view->addParams(array(
			new DevblocksSearchCriteria(SearchFields_Message::TICKET_MASK, '=', $ticket->mask)
		), true);
	}
	
	function getMessageAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		CerberusContexts::getContext(CerberusContexts::CONTEXT_MESSAGE, $id, $labels, $values);
		$dict = new DevblocksDictionaryDelegate($values);
		
		$tpl->assign('dict', $dict);
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket/message.tpl');
		exit;
	}
	
};
endif;