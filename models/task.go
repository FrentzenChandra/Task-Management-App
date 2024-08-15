package models

import "time"

type Task struct {
	Id          int    `json:"id" gorm:"type:int; primaryKey; autoIncrement"`
	UserId      int    `json:"userId" gorm:"type:int"`
	Title       string `json:"title" gorm:"type:varchar(255)"`
	Description string `json:"description" gorm:"type:text"`
	Status      string `json:"status" gorm:"type:varchar(50)"`
	// default nya kosong jadi jika tidak ada isinya maka diisi "" (kosong)
	Reason       string    `json:"reason" gorm:"type:text; default:"`
	Revision     int       `json:"revision" gorm:"type:int; default:0"`
	DueDate      string    `json:"dueDate" gorm:"type:varchar(50)"`
	SubmitDate   string    `json:"submitDate" gorm:"type:varchar(50)"`
	RejectedDate string    `json:"rejectedDate" gorm:"type:varchar(50)"`
	ApprovedDate string    `json:"approvedDate" gorm:"type:varchar(50)"`
	Attachment   string    `json:"attachment" gorm:"type:varchar(255)"`
	CreatedAt    time.Time `json:"createdAt" gorm:"type:timestamp; default:CURRENT_TIMESTAMP"`
	UpdatedAt    time.Time `json:"updatedAt" gorm:"type:timestamp; default:NULL"`
	DeletedAt    time.Time `json:"deletedAt" gorm:"type:timestamp; default:NULL"`
	User         User      `json:"user,omitempty" gorm:"foreignKey:UserId"` // Punya :
}
