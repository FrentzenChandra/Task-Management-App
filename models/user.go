package models

import (
	"time"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type User struct {
	// auto increment berguna untuk otomatis ada isi
	// json disini berguna untuk nanti response atau pun mengisi data
	// dengan tipe data struct ini json akan mengisi data id dengan json id
	Id        int       `json:"id" gorm:"type:int;primaryKey; pautoIncrement"`
	Role      string    `json:"role" gorm:"type:varchar(10)"`
	Name      string    `json:"name" gorm:"type:varchar(255)"`
	Email     string    `json:"email" gorm:"type:varchar(50); UNIQUE"`
	Password  string    `json:"password" gorm:"type:varchar(255)"`
	CreatedAt time.Time `json:"created_at"`
	UpdateAt  time.Time `json:"updated_at"`
	// Tujuan Cascade ini adalah jika kita menghapus sebuah user maka task yang ada
	// pada user yang ingin dihapus juga ikutan terhapus
	Tasks []Task `json:"tasks,omitempty" gorm:"constraint:OnDelete:CASCADE"`
}

func (u *User) AfterDelete(tx *gorm.DB) (err error) {
	// Ini berguna untuk Jika ada user 1 yang dihapus maka gorm akan mencari apakah ada
	// task yang memiliki user_id yang sama. Jika ada maka gorm akan menghapus task tersebut
	// juga secara otomatis
	tx.Clauses(clause.Returning{}).Where("user_id= ?", u.Id).Delete(&Task{})
	return
}
