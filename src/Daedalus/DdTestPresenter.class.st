Class {
	#name : 'DdTestPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleLabel',
		'submitButton',
		'genderGroup',
		'date',
		'listPresenter',
		'hobbyGroup',
		'nameInputPresenter',
		'agreeCheckBox',
		'checkBox',
		'button1',
		'checkbox1',
		'label1',
		'list1',
		'button2',
		'datepicker1',
		'textarea1',
		'timepicker1',
		'timepicker2',
		'combobox1',
		'slider1',
		'progressbar1',
		'textinput1',
		'textinput2',
		'label2',
		'groupofradiobuttons1',
		'textinput3',
		'groupofcheckboxes1',
		'groupofradiobuttons2',
		'textinput4',
		'datepicker2',
		'combobox2',
		'textinput5',
		'groupofcheckboxes2',
		'timepicker3'
	],
	#category : 'Daedalus-Daedalus-Examples',
	#package : 'Daedalus',
	#tag : 'Daedalus-Examples'
}

{ #category : 'layout' }
DdTestPresenter >> defaultLayout [

	^ SpBoxLayout new
		  spacing: 10;
		  add: titleLabel height: 26;
		  add: listPresenter height: 67;
		  add: agreeCheckBox height: 35;
		  add: genderGroup height: 53;
		  add: hobbyGroup height: 49;
		  add: submitButton expand: false;
		  yourself
]

{ #category : 'initialization' }
DdTestPresenter >> initializePresenters [

	super initializePresenters.
	timepicker3 := PresenterDecorator wrap: TimePickerPresenter.
	groupofcheckboxes2 := PresenterDecorator wrap: CheckboxGroupPresenter.
	textinput5 := PresenterDecorator wrap: TextInputPresenter.
	combobox2 := PresenterDecorator wrap: ComboBoxPresenter.
	datepicker2 := PresenterDecorator wrap: SpDatePresenter.
	textinput4 := PresenterDecorator wrap: TextInputPresenter.
	groupofradiobuttons2 := PresenterDecorator wrap: RadioGroupPresenter.
	groupofcheckboxes1 := PresenterDecorator wrap: CheckboxGroupPresenter.
	textinput3 := PresenterDecorator wrap: TextInputPresenter.
	groupofradiobuttons1 := PresenterDecorator wrap: RadioGroupPresenter.
	label2 := PresenterDecorator wrap: SpLabelPresenter.
	textinput2 := PresenterDecorator wrap: TextInputPresenter.
	textinput1 := PresenterDecorator wrap: TextInputPresenter.
	progressbar1 := PresenterDecorator wrap: SpProgressBarPresenter.
	slider1 := PresenterDecorator wrap: SpSliderPresenter.
	combobox1 := PresenterDecorator wrap: ComboBoxPresenter.
	timepicker2 := PresenterDecorator wrap: TimePickerPresenter.
	timepicker1 := PresenterDecorator wrap: TimePickerPresenter.
	textarea1 := PresenterDecorator wrap: SpTextPresenter.
	datepicker1 := PresenterDecorator wrap: SpDatePresenter.
	button2 := PresenterDecorator wrap: SpButtonPresenter.
	list1 := PresenterDecorator wrap: SpListPresenter.
	label1 := PresenterDecorator wrap: SpLabelPresenter.
	checkbox1 := PresenterDecorator wrap: SpCheckBoxPresenter.
	button1 := PresenterDecorator wrap: SpButtonPresenter.
	button1
		height: 20;
		backgroundColor: '#red';
		label: 'Hello!'.
	checkBox := SpCheckBoxPresenter new.
	checkBox label: 'Check'.
	titleLabel := LabelPresenter new.
	titleLabel label: 'Test form'.
	submitButton := ButtonPresenter new.
	submitButton label: 'Submit'.
	nameInputPresenter := TextInputPresenter new.
	nameInputPresenter
		text: 'Olesia';
		placeholder: 'Enter your name'.
	date := PresenterDecorator wrap: SpDatePresenter.
	date date: '20 June 2026'.
	agreeCheckBox := CheckboxPresenter new.
	agreeCheckBox
		state: false;
		fontSize: 11;
		label: 'I agree';
		fontSize: 11;
		state: true;
		label: 'I agree'.
	genderGroup := RadioGroupPresenter new.
	genderGroup
		itemSelected: 1;
		items: #( 'male' 'female' 'other' );
		showFrame: false;
		showTitle: true;
		сolumnCount: 3;
		title: 'Gender';
		itemSelected: 1;
		showFrame: false;
		showTitle: true;
		title: 'Gender';
		items: #( 'male' 'female' 'other' );
		сolumnCount: 3.
	listPresenter := ListPresenter new.
	listPresenter items: #( '1' '3' '6' '7' '4' '8' '13' ).
	hobbyGroup := CheckboxGroupPresenter new.
	hobbyGroup
		selectedIndexes: #( 1 2 3 );
		items: #( 'Cooking' 'Traveling' 'Running' );
		showFrame: false;
		showTitle: false;
		сolumnCount: 2;
		title: 'Hobby';
		items: #( 'Cooking' 'Traveling' 'Running' );
		selectedIndexes: #( 1 2 3 );
		showFrame: false;
		showTitle: false;
		сolumnCount: 2;
		title: 'Hobby'
]
