Class {
	#name : 'DdTestPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleLabel',
		'table',
		'textArea',
		'submitButton',
		'genderGroup',
		'prioritySlider',
		'progressBar',
		'combobox',
		'date',
		'time',
		'newButton',
		'listPresenter',
		'hobbyGroup',
		'nameInputPresenter',
		'label1',
		'agreeCheckBox'
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
		  add: nameInputPresenter expand: true;
		  add: combobox expand: false;
		  add: agreeCheckBox expand: false;
		  add: genderGroup expand: false;
		  add: hobbyGroup expand: false;
		  add: table expand: true;
		  add: submitButton expand: false;
		  add: newButton;
		  yourself
]

{ #category : 'initialization' }
DdTestPresenter >> initializePresenters [
   |items|
	super initializePresenters.
	label1 := PresenterDecorator wrap: SpLabelPresenter.
	label1 label: 'Label'.
	newButton := PresenterDecorator wrap: SpButtonPresenter.
	newButton label: 'New button'.

	titleLabel := LabelPresenter new.
	titleLabel label: 'Test form'.

	table := SpTablePresenter new.
items := OrderedCollection new.
items add: (Dictionary new at: #name put: 'Alice'; at: #age put: 25; at: #city put: 'Lviv'; yourself).
items add: (Dictionary new at: #name put: 'Bob'; at: #age put: 30; at: #city put: 'Kyiv'; yourself).
items add: (Dictionary new at: #name put: 'Charlie'; at: #age put: 22; at: #city put: 'Odesa'; yourself).

table
    addColumn: (SpStringTableColumn title: 'Name' evaluated: [ :p | p at: #name ]);
    addColumn: (SpStringTableColumn title: 'Age' evaluated: [ :p | (p at: #age) printString ]);
    addColumn: (SpStringTableColumn title: 'City' evaluated: [ :p | p at: #city ]);
    items: items.

	textArea := PresenterDecorator wrap: SpTextPresenter.
	textArea beNotWrapWord.
	textArea text:
		'I am text area! I am text area! I am text area! I am text area! I am text area! I am text area!'.


	submitButton := ButtonPresenter new.
	submitButton label: 'Submit'.

	nameInputPresenter := TextInputPresenter new.
	nameInputPresenter text: 'Olesiа'.
	nameInputPresenter placeholder: 'Enter your name'.

	combobox := ComboBoxPresenter new.
	combobox selectIndex: 0.
	combobox items: #( 'Apple' 'Banana' 'Cherry' 'Orange' ).

	date := PresenterDecorator wrap: SpDatePresenter.
	date date: '20 June 2026'.

	agreeCheckBox := CheckboxPresenter new.
	agreeCheckBox state: true.
	agreeCheckBox label: 'I agree'.

	genderGroup := RadioGroupPresenter new.
	genderGroup itemSelected: 1.
	genderGroup showFrame: false.
	genderGroup showTitle: false.
	genderGroup title: 'Gender'.
	genderGroup items: #( 'male' 'female' 'other' ).
	genderGroup сolumnCount: 3.

	listPresenter := ListPresenter new.
	listPresenter items: #( '1' '2' '3' '4' '5' '6' ).

	hobbyGroup := CheckboxGroupPresenter new.
	hobbyGroup items:
		#( 'Cooking' 'Traveling' 'Reading' 'Programming' 'Painting' ).
	hobbyGroup showFrame: false.
	hobbyGroup showTitle: true.
	hobbyGroup сolumnCount: 3.
	hobbyGroup title: 'Hobby'.
	prioritySlider := PresenterDecorator wrap: SpSliderPresenter.
	prioritySlider quantum: 3.
	prioritySlider label: 'Slider'.
	prioritySlider value: 100.
	prioritySlider max: 200.
	prioritySlider min: 5.

	time := TimePickerPresenter new.

	progressBar := PresenterDecorator wrap: SpProgressBarPresenter.
	agreeCheckBox color: '#green'
]
