package dto

type CommonDTO struct {
	Code int         `json:"code"`
	Msg  string      `json:"msg"`
	Data interface{} `json:"data,omitempty"`
}

func SuccessResponse(data interface{}) *CommonDTO {
	return &CommonDTO{
		Code: 0,
		Msg:  "success",
		Data: data,
	}
}

func ErrorResponse(code int, msg string) *CommonDTO {
	return &CommonDTO{
		Code: code,
		Msg:  msg,
	}
}
