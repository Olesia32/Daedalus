Class {
	#name : 'DdTestPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleLabel',
		'table',
		'list',
		'textArea',
		'submitButton',
		'nameInput',
		'agreeCheckbox',
		'genderGroup',
		'hobyGroup',
		'prioritySlider',
		'progressBar',
		'combobox',
		'date',
		'time'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'layout' }
DdTestPresenter >> defaultLayout [

	^ SpBoxLayout new
		  spacing: 10;
		  add: titleLabel expand: false;
		  add: nameInput expand: true;
		  add: combobox expand: false;
		  add: agreeCheckbox expand: false;
		  add: genderGroup expand: false;
		  add: hobyGroup expand: false;
		  add: textArea expand: true;
		  add: submitButton expand: false;
		  yourself
]

{ #category : 'initialization' }
DdTestPresenter >> initializePresenters [

	super initializePresenters.

	titleLabel := LabelPresenter new.
	titleLabel label: 'Test form'.

	table := PaginatedTablePresenter new.
	table
		columns: {
				('Name' -> #name).
				('Email' -> #email).
				('Role' -> #role) };
		items: {
				(Dictionary new
					 at: #name put: 'Alice';
					 at: #email put: 'alice@example.com';
					 at: #role put: 'Admin';
					 yourself).

				(Dictionary new
					 at: #name put: 'Bob';
					 at: #email put: 'bob@example.com';
					 at: #role put: 'User';
					 yourself).

				(Dictionary new
					 at: #name put: 'Charlie';
					 at: #email put: 'charlie@example.com';
					 at: #role put: 'Moderator';
					 yourself) };
		itemsPerPage: 2.

	textArea := PresenterDecorator wrap: SpTextPresenter.
	textArea beNotWrapWord.
	textArea text:
		'I am text area! I am text area! I am text area! I am text area! I am text area! I am text area!'.


	submitButton := ButtonPresenter new.
	submitButton label: 'Submit'.

	nameInput := TextInputPresenter new.
	nameInput text: 'Olesiа'.
	nameInput placeholder: 'Enter your name'.

	combobox := ComboBoxPresenter new.
	combobox selectIndex: 0.
	combobox items: #( 'Apple' 'Banana' 'Cherry' 'Orange' ).

	date := PresenterDecorator wrap: SpDatePresenter.
	date date: '20 June 2026'.

	agreeCheckbox := CheckboxPresenter new.
	agreeCheckbox state: false.
	agreeCheckbox label: 'I agree'.

	genderGroup := RadioGroupPresenter new.
	genderGroup itemSelected: 1.
	genderGroup showFrame: false.
	genderGroup showTitle: true.
	genderGroup title: 'Gender'.
	genderGroup items: #('male' 'female' 'other').
	genderGroup сolumnCount: 3.

	list := ListPresenter new.
	list items: #( '1' '2' '3' '4' '5' '6' ).

	hobyGroup := CheckboxGroupPresenter new.
	hobyGroup items:
		#( 'Cooking' 'Traveling' 'Reading' 'Programming' 'Painting' ).
	hobyGroup showFrame: false.
	hobyGroup showTitle: true.
	hobyGroup сolumnCount: 3.
	hobyGroup title: 'Hobby'.
	prioritySlider := PresenterDecorator wrap: SpSliderPresenter.
	prioritySlider quantum: 3.
	prioritySlider label: 'Slider'.
	prioritySlider value: 100.
	prioritySlider max: 200.
	prioritySlider min: 5.

	time := TimePickerPresenter new.

	progressBar := PresenterDecorator wrap: SpProgressBarPresenter.
	titleLabel fontSize: 12.
	agreeCheckbox fontSize: 12.
	agreeCheckbox color: '#green'
]
