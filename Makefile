SHELL := $(shell which bash)
pypath := /opt/homebrew/bin /usr/bin /usr/local/bin
syspy := $(shell for x in $(pypath); do [[ -f $${x}/python3 ]] && echo $${x}/python3 && exit; done)

# check if virtual environment is activated
activate := source bin/activate

# pip dependencies
deps := ultralytics

models := yolo11n.pt yolov11n-face.pt
yolo11n.pt.url := https://github.com/ultralytics/assets/releases/download/v8.3.0/yolo11n.pt
yolov11n-face.pt.url := https://github.com/akanametov/yolo-face/releases/download/v0.0.0/yolov11n-face.pt

venv_files := bin include lib pyvenv.cfg lib64 share

rm = $(if $(wildcard $(1)),rm -rf $(wildcard $(1)),)

init:
	[[ -f pyvenv.cfg ]] || $(syspy) -m venv .

# download models in $(models) environment
models: FORCE
	$(foreach m,$(models), [[ -f models/$(m) ]] || wget -O models/$(m) '$($(m).url)';)

deps:
	$(activate); pip install $(deps)

clean:
	$(call rm,$(venv_files))

.PHONY: FORCE

sync:
	rsync -azvp ./ root@archvm.local.rs:yolo-example/ $(foreach x,$(venv_files),--exclude $(x))

.gitignore: FORCE
	rm .gitignore
	$(foreach x,$(venv_files) runs assets models,echo '$(x)' >> .gitignore;)

detect:
	$(activate); yolo task=detect mode=predict model=models/yolov11n-face.pt conf=0.25 imgsz=1280 line_thickness=1 max_det=1000 source=assets/24mse.jpg
