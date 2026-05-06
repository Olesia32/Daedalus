Class {
	#name : 'DdTestPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleLabel',
		'submitButton',
		'nameInput',
		'agreeCheckbox',
		'genderGroup',
		'prioritySlider',
		'progressBar'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'layout' }
DdTestPresenter >> defaultLayout [ 
    ^ SpBoxLayout newTopToBottom
        spacing: 10;
        add: titleLabel expand: false;
        add: nameInput expand: false;
        add: agreeCheckbox expand: false;
        add: genderGroup expand: false;
        add: prioritySlider expand: false;
        add: progressBar expand: false;
        add: submitButton expand: false;
        yourself
]

{ #category : 'initialization' }
DdTestPresenter >> initializePresenters [

	super initializePresenters.

	titleLabel := LabelPresenter new.
	titleLabel label: 'Test'.

	submitButton := ButtonPresenter new.
	submitButton label: 'Submit'.

	nameInput := TextInputPresenter new.
	nameInput text: 'Olesi'.
	nameInput placeholder: 'Enter your name'.

	agreeCheckbox := CheckboxPresenter new.
	agreeCheckbox state: false.
	agreeCheckbox label: 'I agree'.

	genderGroup := RadioGroupPresenter new.
	genderGroup showFrame: false.
	genderGroup showTitle: true.
	genderGroup title: 'Gender'.
	genderGroup items: #( 'male' 'female' ).
	genderGroup сolumnCount: 1.

	prioritySlider := PresenterDecorator wrap: SpSliderPresenter.
	prioritySlider quantum: 3.
	prioritySlider label: 'Slider'.
	prioritySlider value: 100.
	prioritySlider max: 200.
	prioritySlider min: 5.

	progressBar := PresenterDecorator wrap: SpProgressBarPresenter.
	titleLabel fontSize: 12.
	agreeCheckbox fontSize: 10.
	agreeCheckbox color: '#green'
]
