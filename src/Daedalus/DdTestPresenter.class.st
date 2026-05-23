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
		'checkBox'
	],
	#category : 'Daedalus-Daedalus-Examples',
	#package : 'Daedalus',
	#tag : 'Daedalus-Examples'
}

{ #category : 'layout' }
DdTestPresenter >> defaultLayout [

	^ SpBoxLayout new
		  spacing: 10;
		  add: titleLabel expand: false;
		  add: nameInputPresenter expand: false;
		  add: checkBox expand: false;
		  add: agreeCheckBox expand: false;
		  add: genderGroup expand: false;
		  add: hobbyGroup expand: false;
		  add: listPresenter expand: true;
		  add: submitButton expand: false;
		  yourself
]

{ #category : 'initialization' }
DdTestPresenter >> initializePresenters [

	super initializePresenters.
	checkBox := SpCheckBoxPresenter new.
	checkBox label: 'Check'.

	titleLabel := LabelPresenter new.
	titleLabel fontSize: 10.
	titleLabel label: 'Test form!'.

	submitButton := ButtonPresenter new.
	submitButton label: 'Submit'.

	nameInputPresenter := TextInputPresenter new.
	nameInputPresenter text: 'Olesia'.
	nameInputPresenter placeholder: 'Enter your name'.

	date := PresenterDecorator wrap: SpDatePresenter.
	date date: '20 June 2026'.

	agreeCheckBox := CheckboxPresenter new.
	agreeCheckBox fontSize: 11.
	agreeCheckBox state: true.
	agreeCheckBox label: 'I agree'.

	genderGroup := RadioGroupPresenter new.
	genderGroup itemSelected: 1.
	genderGroup showFrame: false.
	genderGroup showTitle: true.
	genderGroup title: 'Gender'.
	genderGroup items: #( 'male' 'female' ).
	genderGroup сolumnCount: 2.

	listPresenter := ListPresenter new.
	listPresenter items: #( '1' '2' '3' '5' '6' '7' '4' ).

	hobbyGroup := CheckboxGroupPresenter new.
	hobbyGroup items: #( 'Cooking' 'Traveling' 'Programming'
	   'Running' ).
	hobbyGroup selectedIndexes: #( 1 2 3 ).
	hobbyGroup showFrame: false.
	hobbyGroup showTitle: true.
	hobbyGroup сolumnCount: 2.
	hobbyGroup title: 'Hobby'
]
