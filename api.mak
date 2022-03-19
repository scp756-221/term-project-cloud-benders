#
# Front-end to bring some sanity to the litany of tools and switches
# in calling the sample application from the command line.
#
# This file covers off driving the API independent of where the cluster is
# running.
# Be sure to set your context appropriately for the log monitor.
#
# The intended approach to working with this makefile is to update select
# elements (body, id, IP, port, etc) as you progress through your workflow.
# Where possible, stodout outputs are tee into .out files for later review.
#


KC=kubectl
CURL=curl

# Keep all the logs out of main directory
LOG_DIR=logs

# look these up with 'make ls'
# You need to specify the container because istio injects side-car container
# into each pod.
# s1: service1; s2: service2; db: cmpt756db
PODS1=pod/cmpt756s1-8557865b4b-jnwrj
PODCONT=service1

# show deploy and pods in current ns; svc of cmpt756 ns
ls: showcontext
	$(KC) get gw,deployments,pods
	$(KC) -n $(NS) get svc

logs:
	$(KC) logs $(PODS1) -c $(PODCONT)

#
# Replace this with the external IP/DNS name of your cluster
#
# In all cases, look up the external IP of the istio-ingressgateway LoadBalancer service
# You can use either 'make -f eks.m extern' or 'make -f mk.m extern' or
# directly 'kubectl -n istio-system get service istio-ingressgateway'
#
#IGW=172.16.199.128:31413
#IGW=10.96.57.211:80
#IGW=a344add95f74b453684bcd29d1461240-517644147.us-east-1.elb.amazonaws.com:80
IGWU=0.0.0.0:30000
IGWM=0.0.0.0:30001
IGWP=0.0.0.0:30003

# stock body & fragment for API requests
BODY_USER= { \
"fname": "Sherlock", \
"email": "sholmes@baker.org", \
"lname": "Holmes" \
}

BODY_UID= { \
    "uid": "0d2a2931-8be6-48fc-aa9e-5a0f9f536bd3" \
}

BODY_MUSIC= { \
  "Artist": "Duran Duran", \
  "SongTitle": "Rio" \
}

BODY_PLAY= { \
  "Playlist": "Default", \
  "Songs": "Hills, Infinity, Blah" \
}

# this is a token for ???
TOKEN=Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMDI3Yzk5ZWYtM2UxMi00ZmM5LWFhYzgtMTcyZjg3N2MyZDI0IiwidGltZSI6MTYwMTA3NDY0NC44MTIxNjg2fQ.hR5Gbw5t2VMpLcj8yDz1B6tcWsWCFNiHB_KHpvQVNls
BODY_TOKEN={ \
    "jwt": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMDI3Yzk5ZWYtM2UxMi00ZmM5LWFhYzgtMTcyZjg3N2MyZDI0IiwidGltZSI6MTYwMTA3NDY0NC44MTIxNjg2fQ.hR5Gbw5t2VMpLcj8yDz1B6tcWsWCFNiHB_KHpvQVNls" \
}

# keep these ones around
USER_ID=0d2a2931-8be6-48fc-aa9e-5a0f9f536bd3
MUSIC_ID=2995bc8b-d872-4dd1-b396-93fde2f4bfff
PLAY_ID=395c9000-16b0-450b-bdb6-c91f003eacb4

# it's convenient to have a second set of id to test deletion (DELETE uses these id with the suffix of 2)
USER_ID2=9175a76f-7c4d-4a3e-be57-65856c6bb77e
MUSIC_ID2=8ed63e4f-3b1e-47f8-beb8-3604516e5a2d
PLAY_ID2=8ed63e4f-3b1e-47f8-beb8-3604516e5a2d


# POST is used for user (apipost) or music (apimusic) to create a new record
cuser:
	$(CURL) --location --request POST 'http://$(IGWU)/api/user/' --header 'Content-Type: application/json' --data-raw '$(BODY_USER)' | tee -a $(LOG_DIR)/cuser.out

cmusic:
	$(CURL) --location --request POST 'http://$(IGWM)/api/music/' --header '$(TOKEN)' --header 'Content-Type: application/json' --data-raw '$(BODY_MUSIC)' | tee -a $(LOG_DIR)/cmusic.out

cplay:
	$(CURL) --location --request POST 'http://$(IGWP)/api/playlist/' --header '$(TOKEN)' --header 'Content-Type: application/json' --data-raw '$(BODY_PLAY)' | tee -a $(LOG_DIR)/cplay.out

# PUT is used for user (update) to update a record
uuser:
	$(CURL) --location --request PUT 'http://$(IGWU)/api/user/$(USER_ID)' --header '$(TOKEN)' --header 'Content-Type: application/json' --data-raw '$(BODY_USER)' | tee -a $(LOG_DIR)/uuser.out

# GET is used with music to read a record
rmusic:
	$(CURL) --location --request GET 'http://$(IGWM)/api/music/$(MUSIC_ID)' --header '$(TOKEN)' | tee -a $(LOG_DIR)/rmusic.out

# DELETE is used with user or music to delete a record
duser:
	$(CURL) --location --request DELETE 'http://$(IGWU)/api/user/$(USER_ID2)' --header '$(TOKEN)' | tee -a $(LOG_DIR)/duser.out

dmusic:
	$(CURL) --location --request DELETE 'http://$(IGWM)/api/music/$(MUSIC_ID2)' --header '$(TOKEN)' | tee -a $(LOG_DIR)/dmusic.out

# PUT is used for login/logoff too
apilogin:
	$(CURL) --location --request PUT 'http://$(IGWU)/api/user/login' --header 'Content-Type: application/json' --data-raw '$(BODY_UID)' | tee -a $(LOG_DIR)/apilogin.out

apilogoff:
	$(CURL) --location --request PUT 'http://$(IGWU)/api/user/logoff' --header 'Content-Type: application/json' --data-raw '$(BODY_TOKEN)' | tee -a $(LOG_DIR)/apilogoff.out


showcontext:
	$(KC) config get-contexts

